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
        ::JSON.dump data
      end

      def decode(body)
        ::JSON.load body
      end
    end

    # @deprecated
    JsonDecoder = JSON

    # @deprecated
    JsonEncoder = JSON
  end
end
