module Acfs
  class Service

    # Allows to queue request on this service that will be
    # delegated to global Acfs adapter queue.
    #
    module Queue

      # Queue a new request on global adapter queue.
      #
      def queue(request)
        Acfs.adapter.queue request
      end
    end
  end
end
