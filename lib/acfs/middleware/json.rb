# frozen_string_literal: true

require 'json'

module Acfs
  module Middleware
    # A middleware to encore request data using JSON.
    #
    class JSON < Serializer
      def initialize(app, encoder: nil, **kwargs)
        super(app, **kwargs)

        @encoder = encoder || ::JSON
      end

      def mime
        ::Mime[:json]
      end

      def encode(data)
        # Improve rails compatibility by manually checking for `#as_json`.
        # Several objects behave a bit like JSON via `#as_json` but would
        # otherwise be converted to strings by `JSON.dump`.
        data = data.as_json if data.respond_to?(:as_json)

        @encoder.dump(data)
      end

      def decode(body)
        @encoder.parse(body)
      rescue StandardError => e
        raise ::JSON::ParserError.new(e)
      end
    end

    # @deprecated
    JsonDecoder = JSON

    # @deprecated
    JsonEncoder = JSON
  end
end
