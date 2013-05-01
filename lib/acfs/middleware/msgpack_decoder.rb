require 'msgpack'
require 'action_dispatch'

module Acfs
  module Middleware

    # Register msgpack mime type
    ::Mime::Type.register 'application/x-msgpack', :msgpack

    # A middleware to decode Message Pack responses.
    #
    class MessagePackDecoder < Base

      CONTENT_TYPES = %w(application/x-msgpack)

      def response(response, nxt)
        response.data = ::MessagePack.unpack(response.body) if message_pack?(response)
        nxt.call response
      end

      def message_pack?(response)
        CONTENT_TYPES.include? response.content_type
      end
    end
  end
end
