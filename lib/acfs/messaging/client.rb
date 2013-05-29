require 'bunny'

module Acfs::Messaging

  # @macro experimental
  #
  class Client

    def initialize
      @bunny ||= Bunny.new.tap do |bunny|
        bunny.start
      end
    end

    def channel
      @channel ||= @bunny.create_channel
    end

    def exchange
      @exchange ||= channel.topic 'acfs-0.17.0-2', auto_delete: true
    end

    def publish(routing_key, message)
      exchange.publish ::MessagePack.pack(message), routing_key: routing_key.to_s
    end

    class << self

      def instance
        @instance ||= new
      end

      def register(receiver)
        @receivers ||= []
        @receivers << receiver.instance.tap { |r| r.init instance }
      end
    end
  end
end
