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
