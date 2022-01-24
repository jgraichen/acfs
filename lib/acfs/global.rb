# frozen_string_literal: true

module Acfs
  #
  # Global Acfs module methods.
  #
  module Global
    #
    # @api private
    # @return [Runner]
    #
    def runner
      Thread.current[:acfs_runner] ||= begin
        adapter = Configuration.current.adapter

        if adapter
          Runner.new adapter.call
        else
          Runner.new Adapter::Typhoeus.new
        end
      end
    end

    # @api public
    #
    # Run all queued operations.
    #
    # @return [undefined]
    #
    def run
      ::ActiveSupport::Notifications.instrument 'acfs.before_run'
      ::ActiveSupport::Notifications.instrument 'acfs.run' do
        runner.start
      end
    end

    # @api public
    #
    # Configure acfs using given block.
    #
    # @return [undefined]
    # @see Configuration#configure
    #
    def configure(&block)
      Configuration.current.configure(&block)
    end

    # @api public
    #
    # Reset all queues, stubs and internal state.
    #
    def reset
      ::ActiveSupport::Notifications.instrument 'acfs.reset' do
        runner.clear
        Acfs::Stub.clear
      end
    end

    # @api public
    #
    # Add an additional callback hook to not loaded resource.
    # If given resource already loaded callback will be invoked immediately.
    #
    # This method will be replaced by explicit callback
    # handling when query methods return explicit future objects.
    #
    # @example
    #   user = MyUser.find 1, &callback_one
    #   Acfs.add_callback(user, &callback_two)
    #
    def add_callback(resource, &block)
      unless resource.respond_to?(:__callbacks__)
        raise ArgumentError.new 'Given resource is not an Acfs resource ' \
                                "delegator but a: #{resource.class.name}"
      end
      return false if block.nil?

      if resource.nil? || resource.loaded?
        yield resource
      else
        resource.__callbacks__ << block
      end
    end

    def on(*resources)
      # If all resources have already been loaded, we run the callback immediately.
      if resources.all? {|res| res.nil? || res.loaded? }
        yield(*resources)
        return
      end

      # Otherwise, we add a callback to *each* resource with a guard that ensures
      # that only the very last resource being loaded executes the callback.
      resources.each do |resource|
        add_callback resource do |_|
          yield(*resources) if resources.all? {|res| res.nil? || res.loaded? }
        end
      end
    end
  end
end
