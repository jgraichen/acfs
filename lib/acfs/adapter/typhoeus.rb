require 'typhoeus'

module Acfs
  module Adapter

    # Adapter for Typhoeus.
    #
    class Typhoeus

      # Run all queued requests.
      #
      def run(request = nil)
        return hydra.run unless request

        convert_request(request).run
      end

      # Add a new request or URL to the queue.
      #
      def queue(req)
        hydra.queue convert_request(req)
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
        Acfs::Response.new(request, response.code, response.headers, response.body)
      end
    end
  end
end
