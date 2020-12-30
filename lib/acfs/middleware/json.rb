# frozen_string_literal: true

require 'json'

module Acfs
  module Middleware
    # A middleware to encore request data using JSON.
    #
    class JSON < Serializer
      def mime
        ::Mime[:json]
      end

      def encode(data)
        # Improve rails compatibility by manually checking for `#as_json`.
        # Several objects behave a bit like JSON via `#as_json` but would
        # otherwise be converted to strings by `JSON.dump`.
        data = data.as_json if data.respond_to?(:as_json)

        ::JSON.dump(data)
      end

      def decode(body)
        ::JSON.parse(body)
      end
    end

    # @deprecated
    JsonDecoder = JSON

    # @deprecated
    JsonEncoder = JSON
  end
end
