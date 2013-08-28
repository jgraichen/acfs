require 'rack/utils'

module Acfs

  # Global handler for stubbing resources.
  #
  class Stub
    ACTIONS = [ :read, :create, :update, :delete, :list ]

    attr_reader :opts

    def initialize(opts)
      @opts = opts
      @opts[:with].stringify_keys! if @opts[:with].respond_to? :stringify_keys
    end

    def accept?(op)
      return opts[:with].call op if opts[:with].respond_to? :call

      params = op.full_params.stringify_keys
      data   = op.data.stringify_keys

      opts[:with] == params || data == opts[:with]
    end

    def calls
      @calls ||= []
    end

    def called?(count = nil)
      count = count.count if count.respond_to? :count # For `5.times` Enumerators
      count.nil? ? calls.any? : calls.size == count
    end

    def call(op)
      calls << op

      if (data = opts[:return])
        op.callback.call data
      elsif (err = opts[:raise])
        raise_error op, err, opts[:return]
      else
        raise ArgumentError, 'Unsupported stub.'
      end
    end

    private
    def raise_error(op, name, data)
      raise name if name.is_a? Class

      op.handle_failure ::Acfs::Response.new op.request, status: Rack::Utils.status_code(name), data: data
    end

    class << self

      # Stub a resource with given handler block. An already created handler
      # for same resource class will be overridden.
      #
      def resource(klass, action, opts = {}, &block)
        action = action.to_sym
        raise ArgumentError, "Unknown action `#{action}`." unless ACTIONS.include? action

        Stub.new(opts).tap do |stub|
          stubs[klass] ||= {}
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

      def enable; @enabled = true end
      def disable; @enabled = false end

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

        accepted_stubs = stubs.select { |stub| stub.accept? op }

        raise AmbiguousStubError.new stubs: accepted_stubs, operation: op if accepted_stubs.size > 1

        accepted_stubs.first
      end

      def stubbed(op)
        stub = stub_for op
        unless stub
          return false if allow_requests?
          raise RealRequestsNotAllowedError, "No stub found for #{op.action} on #{op.resource.name} with params #{op.full_params.inspect}, data #{op.data.inspect} and id #{op.id}."
        end

        stub.call op
        true
      end
    end
  end
end
