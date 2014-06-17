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
      ::ActiveSupport::Notifications.instrument 'acfs.operation.before_process', operation: op
      op.synchronous? ? run(op) : enqueue(op)
    end

    # Run operation right now skipping queue.
    #
    def run(op)
      ::ActiveSupport::Notifications.instrument 'acfs.runner.sync_run', operation: op do
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
      return if running?

      enqueue_operations

      @running = true
      adapter.start
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
      req = op.service.prepare op.request
      return unless req.is_a? Acfs::Request
      req = prepare req
      return unless req.is_a? Acfs::Request
      yield req
    end
  end
end
