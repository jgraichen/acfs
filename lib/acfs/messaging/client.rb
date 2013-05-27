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

    def publish(routing_key, message)
      channel.default_exchange.publish MessagePack.pack(message), routing_key: routing_key
    end

    def wait
      @bunny.queue.pop
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
