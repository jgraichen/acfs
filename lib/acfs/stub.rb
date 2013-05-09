
module Acfs

  # Global handler for stubbing resources.
  #
  class Stub

    ACTIONS = [ :read, :create, :update, :delete, :list ]

    class << self

      # Stub a resource with given handler block. An already created handler
      # for same resource class will be overridden.
      #
      def resource(klass, opts = {}, &block)
        action = opts[:action].to_sym
        raise ArgumentError, "Unknown action `#{action}`." unless ACTIONS.include? action

        stubs[klass] ||= {}
        stubs[klass][action] ||= []
        stubs[klass][action] << { args: opts[:with], opts: opts }
      end

      # Clear all stubs.
      #
      def clear(klass = nil)
        klass.nil? ? stubs.clear : stubs[klass].try(:clear)
      end

      def stubs
        @stubs ||= {}
      end
    end
  end
end
