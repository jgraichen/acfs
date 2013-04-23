module Acfs
  class Service

    # Methods to queue or executed request through this service.
    #
    module RequestHandler

      # Queue a new request on global adapter queue.
      #
      def queue(request)
        Acfs.adapter.queue prepare request
      end

      # Executes a request now.
      #
      def run(request)
        Acfs.adapter.run prepare request
      end

      # Prepares a request to be processed through this service.
      #
      def prepare(request)
        request
      end
    end
  end
end
