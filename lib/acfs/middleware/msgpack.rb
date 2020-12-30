# frozen_string_literal: true

require 'msgpack'
require 'action_dispatch'

module Acfs
  module Middleware
    class MessagePack < Serializer
      unless defined?(::Mime::MSGPACK)
        ::Mime::Type.register 'application/x-msgpack', :msgpack
      end

      def mime
        ::Mime[:msgpack]
      end

      def encode(data)
        # Improve rails compatibility by manually checking for `#as_json`. If an
        # object does not as `#to_msgpack` but an `#as_json` method, we call
        # that first to get a "simpler" representation.
        if !data.respond_to?(:to_msgpack) && data.respond_to?(:as_json)
          data = data.as_json
        end

        ::MessagePack.pack data
      end

      def decode(body)
        ::MessagePack.unpack body
      end
    end

    # @deprecated
    MessagePackEncoder = MessagePack

    # @deprecated
    MessagePackDecoder = MessagePack
  end
end
