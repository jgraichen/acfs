require 'multi_json'

module Acfs
  module Middleware
    # A middleware to encore request data using JSON.
    #
    class JSON < Serializer
      def mime
        ::Mime::JSON
      end

      def encode(data)
        ::MultiJson.dump data
      end

      def decode(body)
        ::MultiJson.load body
      end
    end

    JsonDecoder = JSON
    JsonEncoder = JSON
  end
end
