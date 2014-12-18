module Acfs::Adapter
  # Base adapter handling operation queuing
  # and processing.
  #
  class Base
    # Start processing queued requests.
    #
    def start
    end

    # Abort running and queued requests.
    #
    def abort
    end

    # Run request right now skipping queue.
    #
    def run(_)
    end

    # Enqueue request to be run later.
    #
    def queue(_)
    end
  end
end
