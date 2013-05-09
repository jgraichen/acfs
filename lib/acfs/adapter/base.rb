module Acfs::Adapter

  # Base adapter handling operation queuing
  # and processing.
  #
  class Base

    # Process an operation. Synchronous operations will be run
    # and parallel operations will be queued.
    #
    def process(op)
      op.synchronous? ? run(op) : enqueue(op)
    end

    # Return true when adapter is executing queued operations.
    #
    def running?
      defined?(:@running) and @running
    end

    # Start processing queued operations.
    #
    def start
    end

    # Clear list of queued operations.
    #
    def clear
      queue.clear
    end

    # Run operation right now skipping queue.
    #
    def run(_)
    end

    # Enqueue operation to be run later.
    #
    def enqueue(op)
      queue << op
    end

    # Return queue.
    #
    def queue
      @queue ||= []
    end
  end
end
