require 'multi_json'

module Acfs
  module Middleware

    # A middleware to automatically encode and decode JSON request and responses.
    #
    class JsonCoder < Base

      def call(request)
        if request.format == :json and request.data?
          request.body = ::MultiJson.dump(request.data)
          request.headers['Content-Type'] = 'application/json'
        end

        super
      end

      def response(response)
        response.data = ::MultiJson.load(response.body) if response.json?
      end
    end
  end
end
