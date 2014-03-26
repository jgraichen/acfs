require 'acfs/service/middleware'

module Acfs

  # @api private
  #
  class Runner
    include Service::Middleware
    attr_reader :adapter

    def initialize(adapter)
      @adapter = adapter
      @running = false
    end

    # Process an operation. Synchronous operations will be run
    # and parallel operations will be queued.
    #
    def process(op)
      ::ActiveSupport::Notifications.instrument 'acfs.runner.process', operation: op do
        op.synchronous? ? run(op) : enqueue(op)
      end
    end

    # Run operation right now skipping queue.
    #
    def run(op)
      ::ActiveSupport::Notifications.instrument 'acfs.runner.run', operation: op do
        op_request(op) { |req| adapter.run req }
      end
    end

    # List of current queued operations.
    #
    def queue
      @queue ||= []
    end

    # Enqueue operation to be run later.
    #
    def enqueue(op)
      ::ActiveSupport::Notifications.instrument 'acfs.runner.enqueue', operation: op do
        if running?
          op_request(op) { |req| adapter.queue req }
        else
          queue << op
        end
      end
    end

    # Return true if queued operations are currently processed.
    #
    def running?
      @running
    end

    # Start processing queued operations.
    #
    def start
      ::ActiveSupport::Notifications.instrument 'acfs.runner.to_start'
      ::ActiveSupport::Notifications.instrument 'acfs.runner.start' do
        enqueue_operations

        @running = true
        adapter.start
      end
    rescue
      queue.clear
      raise
    ensure
      @running = false
    end

    def clear
      queue.clear
      adapter.abort
      @running = false
    end

    private
    def enqueue_operations
      while (op = queue.shift)
        op_request(op) { |req| adapter.queue req }
      end
    end

    def op_request(op)
      return if Acfs::Stub.enabled? and Acfs::Stub.stubbed(op)
      yield prepare op.service.prepare op.request
    end
  end
end
