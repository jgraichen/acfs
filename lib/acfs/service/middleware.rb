module Acfs
  class Service

    # Module providing all function to register middlewares
    # on services and process queued request through the
    # middleware stack.
    #
    module Middleware
      extend ActiveSupport::Concern

      def prepare(_) # :nodoc:
        self.class.middleware.call super
      end

      module ClassMethods

        # Register a new middleware to be used for this service.
        #
        # class MyService < Acfs::Service
        #   self.base_url = 'http://my.srv'
        #   use Acfs::Middleware::JsonDecoder
        # end
        #
        def use(klass, options = {})
          @middlewares ||= []

          return false if @middlewares.include? klass

          @middlewares << klass
          @middleware = klass.new(middleware, options)
        end

        # Return top most middleware.
        #
        def middleware
          @middleware ||= proc { |request| request}
        end

        # Clear all registered middlewares.
        #
        def clear
          @middleware  = nil
          @middlewares = []
        end
      end
    end
  end
end
