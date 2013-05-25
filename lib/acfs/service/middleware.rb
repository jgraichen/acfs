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

        # @api public
        #
        # Register a new middleware to be used for this service.
        #
        # @example
        #   class MyService < Acfs::Service
        #     self.base_url = 'http://my.srv'
        #     use Acfs::Middleware::JsonDecoder
        #   end
        #
        # @param [Class] klass Middleware class to instantiate and append to middleware stack.
        # @param [Hash, Object] options Options to delegate to middleware class initializer.
        # @return [undefined]
        #
        def use(klass, options = {})
          @middlewares ||= []

          return false if @middlewares.include? klass

          @middlewares << klass
          @middleware = klass.new(middleware, options)
        end

        # @api private
        #
        # Return top most middleware.
        #
        # @return [#call]
        #
        def middleware
          @middleware ||= proc { |request| request}
        end

        # @api public
        #
        # Clear all registered middlewares.
        #
        # @return [undefined]
        #
        def clear
          @middleware  = nil
          @middlewares = []
        end
      end
    end
  end
end
