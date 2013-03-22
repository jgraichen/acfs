require 'multi_json'

module Acfs
  module Middleware

    # A middleware to automatically decode JSON responses.
    #
    class JsonDecoder < Base

      def response(response)
        response.data = ::MultiJson.load(response.body) if response.json?
      end
    end
  end
end
