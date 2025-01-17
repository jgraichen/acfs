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

      if @opts[:return].is_a?(Array) # rubocop:disable Style/GuardClause
        @opts[:return].map! {|h| h.stringify_keys! if h.is_a? Hash }
      end
    end

    def accept?(operation)
      return opts[:with].call(operation) if opts[:with].respond_to?(:call)

      params = operation.full_params.stringify_keys
      data   = operation.data.stringify_keys
      with   = opts[:with]

      return true if with.nil?

      case opts.fetch(:match, :inclusion)
        when :legacy
          return true if with.empty? && params.empty? && data.empty?
          if with.compact == params.compact
            return true
          end
          if with.compact == data.compact
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
      count = count.count if count.respond_to?(:count)

      count.nil? ? calls.any? : calls.size == count
    end

    def call(operation)
      calls << operation

      err  = opts[:raise]
      data = opts[:return]

      if err
        raise_error(operation, err, opts[:return])
      elsif data
        data = data.call(operation) if data.respond_to?(:call)

        response = Acfs::Response.new(
          operation.request,
          headers: opts[:headers] || {},
          status: opts[:status] || 200,
          data: data || {},
        )

        operation.call(data, response)
      else
        raise ArgumentError.new 'Unsupported stub.'
      end
    end

    private

    def raise_error(operation, name, data)
      raise name if name.is_a? Class

      data.stringify_keys! if data.respond_to?(:stringify_keys!)

      operation.handle_failure(
        ::Acfs::Response.new(
          operation.request,
          status: Rack::Utils.status_code(name),
          data: data,
        ),
      )
    end

    class << self
      # Stub a resource with given handler block. An already created handler
      # for same resource class will be overridden.
      #
      def resource(klass, action, opts = {}, &)
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

      def stub_for(operation)
        return false unless (classes = stubs[operation.resource])
        return false unless (stubs = classes[operation.action])

        accepted_stubs = stubs.select {|stub| stub.accept?(operation) }

        if accepted_stubs.size > 1
          raise AmbiguousStubError.new(stubs: accepted_stubs, operation: operation)
        end

        accepted_stubs.first
      end

      def stubbed(operation)
        stub = stub_for(operation)
        unless stub
          return false if allow_requests?

          raise RealRequestsNotAllowedError.new <<~ERROR
            No stub found for `#{operation.action}' on `#{operation.resource.name}' \
            with params `#{operation.full_params.inspect}', data `#{operation.data.inspect}' \
            and id `#{operation.id}'.

            Available stubs:
            #{pretty_print}
          ERROR
        end

        stub.call(operation)
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
