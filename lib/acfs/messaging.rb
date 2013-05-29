require 'acfs/messaging/client'

module Acfs

  # @macro experimental
  #
  module Messaging

    class << self

      # @macro experimental
      #
      # Quick publish a message using default client instance.
      #
      # @param [#to_s] routing_key Routing key.
      # @param [#to_msgpack, Hash] payload Message payload.
      # @return [undefined]
      #
      def publish(routing_key, payload)
        Client.instance.publish routing_key, payload
      end
    end
  end
end
