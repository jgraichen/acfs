# frozen_string_literal: true

require 'rack/utils'

module Acfs
  # Global handler for stubbing resources.
  #
  class Stub
    ACTIONS = %i[read create update delete list].freeze

    attr_reader :opts

    def initialize(opts)
      @opts = opts

      @opts[:with].stringify_keys! if @opts[:with].is_a? Hash
      @opts[:return].stringify_keys! if @opts[:return].is_a? Hash

      if @opts[:return].is_a? Array
        @opts[:return].map! {|h| h.stringify_keys! if h.is_a? Hash }
      end
    end

    def accept?(op)
      return opts[:with].call op if opts[:with].respond_to? :call

      params = op.full_params.stringify_keys
      data   = op.data.stringify_keys
      with   = opts[:with]

      return true if with.nil?

      case opts.fetch(:match, :inclusion)
        when :legacy
          return true if with.empty? && params.empty? && data.empty?
          if with.reject {|_, v| v.nil? } == params.reject {|_, v| v.nil? }
            return true
          end
          if with.reject {|_, v| v.nil? } == data.reject {|_, v| v.nil? }
            return true
          end

          false
        when :inclusion
          with.each_pair.all? do |k, v|
            (params.key?(k) && params[k] == v) || (data.key?(k) && data[k] == v)
          end
      end
    end

    def calls
      @calls ||= []
    end

    def called?(count = nil)
      if count.respond_to? :count
        count = count.count
      end # For `5.times` Enumerators
      count.nil? ? calls.any? : calls.size == count
    end

    def call(op)
      calls << op

      err  = opts[:raise]
      data = opts[:return]

      if err
        raise_error op, err, opts[:return]
      elsif data
        data = data.call(op) if data.respond_to?(:call)

        response = Acfs::Response.new op.request,
          headers: opts[:headers] || {},
          status: opts[:status] || 200,
          data: data || {}
        op.call data, response
      else
        raise ArgumentError.new 'Unsupported stub.'
      end
    end

    private

    def raise_error(op, name, data)
      raise name if name.is_a? Class

      data.stringify_keys! if data.respond_to? :stringify_keys!

      op.handle_failure ::Acfs::Response.new op.request, status: Rack::Utils.status_code(name), data: data
    end

    class << self
      # Stub a resource with given handler block. An already created handler
      # for same resource class will be overridden.
      #
      def resource(klass, action, opts = {}, &_block)
        action = action.to_sym
        unless ACTIONS.include? action
          raise ArgumentError.new "Unknown action `#{action}`."
        end

        Stub.new(opts).tap do |stub|
          stubs[klass]         ||= {}
          stubs[klass][action] ||= []
          stubs[klass][action] << stub
        end
      end

      def allow_requests=(allow)
        @allow_requests = allow ? true : false
      end

      def allow_requests?
        @allow_requests ||= false
      end

      def enabled?
        @enabled ||= false
      end

      def enable
        @enabled = true
      end

      def disable
        @enabled = false
      end

      # Clear all stubs.
      #
      def clear(klass = nil)
        klass.nil? ? stubs.clear : stubs[klass].try(:clear)
      end

      def stubs
        @stubs ||= {}
      end

      def stub_for(op)
        return false unless (classes = stubs[op.resource])
        return false unless (stubs = classes[op.action])

        accepted_stubs = stubs.select {|stub| stub.accept? op }

        if accepted_stubs.size > 1
          raise AmbiguousStubError.new stubs: accepted_stubs, operation: op
        end

        accepted_stubs.first
      end

      def stubbed(op)
        stub = stub_for op
        unless stub
          return false if allow_requests?

          raise RealRequestsNotAllowedError.new <<-MSG.strip.gsub(/^[ ]{12}/, '')
            No stub found for `#{op.action}' on `#{op.resource.name}' with params `#{op.full_params.inspect}', data `#{op.data.inspect}' and id `#{op.id}'.

            Available stubs:
            #{pretty_print}
          MSG
        end

        stub.call op
        true
      end

      private

      def pretty_print
        out = ''
        stubs.each do |klass, actions|
          out << '  ' << klass.name << ":\n"
          actions.each do |action, stubs|
            stubs.each do |stub|
              out << "    #{action}"
              out << " with #{stub.opts[:with].inspect}" if stub.opts[:with]
              if stub.opts[:return]
                out << " and return #{stub.opts[:return].inspect}"
              end
              if stub.opts[:raise]
                out << " and raise #{stub.opts[:raise].inspect}"
              end
              out << "\n"
            end
          end
        end
        out
      end
    end
  end
end
