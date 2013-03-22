module Acfs
  module Middleware

    # A base middleware that does not modify request or response.
    # Can be used as super class for custom middleware implementations.
    #
    class Base
      attr_reader :app, :options

      def initialize(app, options)
        @app     = app
        @options = options
      end

      def call(request)
        request.on_complete { |res| response(res) } if respond_to? :response
        app.call(request)
      end
    end
  end
end
