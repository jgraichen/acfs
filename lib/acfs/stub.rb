require 'rack/utils'

module Acfs

  # Global handler for stubbing resources.
  #
  class Stub
    ACTIONS = [ :read, :create, :update, :delete, :list ]

    class << self

      # Stub a resource with given handler block. An already created handler
      # for same resource class will be overridden.
      #
      def resource(klass, action, opts = {}, &block)
        action = action.to_sym
        raise ArgumentError, "Unknown action `#{action}`." unless ACTIONS.include? action

        opts[:with].stringify_keys! if opts[:with].respond_to? :stringify_keys!

        stubs[klass] ||= {}
        stubs[klass][action] ||= []
        stubs[klass][action] << opts
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
        return false unless (actions = classes[op.action])

        params = op.full_params.stringify_keys
        data   = op.data.stringify_keys

        actions.select do |stub|
          if stub[:with].respond_to? :call
            stub[:with].call op
          else
            stub[:with] == params || data == stub[:with]
          end
        end.first
      end

      def stubbed(op)
        stub = stub_for op
        unless stub
          return false if allow_requests?
          raise RealRequestsNotAllowedError, "No stub found for #{op.action} on #{op.resource.name} with params #{op.full_params.inspect}, data #{op.data.inspect} and id #{op.id}."
        end

        if (data = stub[:return])
          op.callback.call data
        elsif (err = stub[:raise])
          raise_error op, err, stub[:return]
        else
          raise ArgumentError, 'Unsupported stub.'
        end

        true
      end

      private
      def raise_error(op, name, data)
        raise name if name.is_a? Class

        op.handle_failure ::Acfs::Response.new op.request, status: Rack::Utils.status_code(name), data: data
      end
    end
  end
end
