# frozen_string_literal: true

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
    def process(operation)
      ::ActiveSupport::Notifications.instrument('acfs.operation.before_process', operation: operation)
      operation.synchronous? ? run(operation) : enqueue(operation)
    end

    # Run operation right now skipping queue.
    #
    def run(operation)
      ::ActiveSupport::Notifications.instrument('acfs.runner.sync_run', operation: operation) do
        operation_request(operation) {|req| adapter.run req }
      end
    end

    # List of current queued operations.
    #
    def queue
      @queue ||= []
    end

    # Enqueue operation to be run later.
    #
    def enqueue(operation)
      ::ActiveSupport::Notifications.instrument('acfs.runner.enqueue', operation: operation) do
        if running?
          operation_request(operation) {|req| adapter.queue req }
        else
          queue << operation
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
      start_all
    rescue StandardError
      queue.clear
      raise
    end

    def clear
      queue.clear
      adapter.abort
      @running = false
    end

    private

    def start_all
      @running = true
      adapter.start
    ensure
      @running = false
    end

    def enqueue_operations
      while (operation = queue.shift)
        operation_request(operation) {|req| adapter.queue req }
      end
    end

    def operation_request(operation)
      return if Acfs::Stub.enabled? && Acfs::Stub.stubbed(operation)

      req = operation.service.prepare(operation.request)
      return unless req.is_a? Acfs::Request

      req = prepare req
      return unless req.is_a? Acfs::Request

      yield req
    end
  end
end
