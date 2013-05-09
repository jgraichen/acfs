require 'acfs/service/middleware'

module Acfs

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
      op.synchronous? ? run(op) : enqueue(op)
    end

    # Run operation right now skipping queue.
    #
    def run(op)
      adapter.run op_request op
    end

    # List of current queued operations.
    #
    def queue
      @queue ||= []
    end

    # Enqueue operation to be run later.
    #
    def enqueue(op)
      if running?
        adapter.queue op_request op
      else
        queue.append op
        op
        op
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
      enqueue_operations

      @running = true
      adapter.start
      @running = false
    end

    def clear
      queue.clear
      adapter.abort
    end

    private
    def enqueue_operations
      while (op = queue.shift)
        adapter.queue op_request op
      end
    end

    def op_request(op)
      prepare op.service.prepare op.request
    end
  end
end
