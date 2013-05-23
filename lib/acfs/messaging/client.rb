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
