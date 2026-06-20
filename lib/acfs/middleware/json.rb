# frozen_string_literal: true

require 'multi_json'

module Acfs
  module Middleware
    # A middleware to encore request data using JSON.
    #
    class JSON < Serializer
      def mime
        ::Mime[:json]
      end

      def encode(data)
        ::MultiJSON.generate(data)
      end

      def decode(body)
        ::MultiJSON.parse(body)
      rescue ::MultiJSON::ParseError => e
        raise ::JSON::ParserError.new(e)
      end
    end

    # @deprecated
    JsonDecoder = JSON

    # @deprecated
    JsonEncoder = JSON
  end
end
