require 'typhoeus'

module Acfs
  module Adapter

    # Adapter for Typhoeus.
    #
    class Typhoeus < Base

      # Start processing queued operations.
      #
      def start
        while (op = queue.shift) do
          hydra.queue convert_request op.request
        end

        @running = true
        hydra.run
      ensure
        @running = false
      end

      # Clear list of queued operations.
      #
      def clear
        super
        hydra.abort
      end

      # Run operation right now skipping queue.
      #
      def run(op)
        convert_request(op.request).run
      end

      # Queue operation to be run later.
      #
      def enqueue(op)
        if running?
          hydra.queue convert_request op.request
        else
          super
        end
      end

    protected
      def hydra
        @hydra ||= ::Typhoeus::Hydra.new
      end

      def convert_request(req)
        request = ::Typhoeus::Request.new req.url,
                                          method: req.method,
                                          params: req.params,
                                          headers: req.headers,
                                          body: req.body

        request.on_complete do |response|
          req.complete! convert_response(req, response)
        end

        request
      end

      def convert_response(request, response)
        Acfs::Response.new request,
                           status: response.code,
                           headers: response.headers,
                           body: response.body
      end
    end
  end
end
