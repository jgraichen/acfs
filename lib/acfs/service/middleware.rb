require 'acfs/service/middleware/stack'

module Acfs
  class Service
    # Module providing all function to register middlewares
    # on services and process queued request through the
    # middleware stack.
    #
    module Middleware
      extend ActiveSupport::Concern

      # @api private
      # @return [Request]
      #
      def prepare(request)
        self.class.middleware.call request
      end

      module ClassMethods
        # @!method use(klass, *args, &block)
        #   @api public
        #
        #   Register a new middleware to be used for this service.
        #
        #   @example
        #     class MyService < Acfs::Service
        #       self.base_url = 'http://my.srv'
        #       use Acfs::Middleware::JSON
        #     end
        #
        #   @param [Class] klass Middleware class to append
        #   @param [Array<Object>] args Arguments passed to klass initialize
        #   @param [Proc] block Block passed to klass initialize
        #   @return [undefined]
        #
        def use(klass, *args, &block)
          # Backward compatible behavior
          middleware.insert(0, klass, *args, &block)
        end

        # @api private
        #
        # Return top most middleware.
        #
        # @return [#call]
        #
        def middleware
          @middleware ||= Stack.new
        end

        # @deprecated
        delegate :clear, to: :middleware
      end
    end
  end
end
