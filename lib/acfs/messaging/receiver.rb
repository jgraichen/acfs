module Acfs::Messaging

  # @macro experimental
  #
  # A {Receiver} subscribes to a messaging queue and
  # reacts to received messages.
  #
  # @example
  #   class UserWelcomeReceiver < Acfs::Receiver
  #
  module Receiver
    extend ActiveSupport::Concern

    included do
      Acfs::Messaging::Client.register self
    end

    def init(client)
      @channel  = client.channel
      @queue    = @channel.queue self.class.queue, options
      @queue.bind client.exchange, routing_key: self.class.routing_key

      @queue.subscribe do |delivery_info, metadata, payload|
        process_received delivery_info, metadata, payload
      end
    end

    def process_received(delivery_info, metadata, payload)
      return if delivery_info.nil?

      payload = MessagePack.unpack payload
      payload.symbolize_keys! if payload.is_a? Hash
      receive delivery_info, metadata, payload
    end

    def options
      @options ||= self.class.options
    end

    # @macro experimental
    #
    # Handle incoming messages. Should be overridden by derived class.
    #
    def receive(delivery_info, metadata, payload)

    end

    module ClassMethods

      # @macro experimental
      #
      # @overload queue
      #   Return name of queue to listen on. Default name will be
      #   generated based on full class name.
      #
      #   @return [String] Name of queue to listen on.
      #
      # @overload queue(name)
      #   Set queue name to listen on.
      #
      #   @param [String] name Queue name to listen on.
      #   @return [String] Set name of queue to listen on.
      #
      def queue(*args)
        raise ArgumentError.new 'Receiver.queue accepts zero or one argument.' if args.size > 1

        @queue ||= self.name.underscore.gsub('/', '.')
        @queue = args[0].nil? ? nil : args[0].to_s if args.size > 0
        @queue
      end

      # @macro experimental
      #
      # Specify routing key for this receiver. The routing key defines
      # which exchanges should be subscribed to receive messages from.
      #
      # @param [#to_s] key Routing key.
      #
      def route(key)
        @routing_key = key.to_s
      end

      # @macro experimental
      #
      # @overload options
      #   Return configured options for this receiver.
      #
      #   @return [Hash] Configured options.
      #
      # @overload options(opts)
      #   Set configuration options.
      #
      #   @param [Hash] opts Messaging channel options.
      #   @return [Hash] Configured options.
      #
      def options(opts = nil)
        @options ||= {}
        return @options if opts.nil?

        @options = opts.to_hash if opts.respond_to? :to_hash
      end

      # @api private
      #
      # Return configured routing key if any.
      # Default value is `#`.
      #
      # @return [String, Nil] Routing key or `nil`.
      #
      def routing_key
        @routing_key ||= '#'
      end

      def instance
        @instance ||= new
      end
    end
  end
end
