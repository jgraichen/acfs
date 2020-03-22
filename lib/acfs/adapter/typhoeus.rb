# frozen_string_literal: true

require 'typhoeus'

module Acfs
  module Adapter
    # Adapter for Typhoeus.
    #
    class Typhoeus < Base
      def initialize(**kwargs)
        @options = kwargs
      end

      def start
        hydra.run
      rescue StandardError
        @hydra = nil
        raise
      end

      delegate :abort, to: :hydra

      def run(request)
        convert_request(request).run
      end

      def queue(request)
        hydra.queue convert_request request
      end

      protected

      def hydra
        @hydra ||= ::Typhoeus::Hydra.new(**@options)
      end

      def convert_request(req)
        request = ::Typhoeus::Request.new req.url,
          method: req.method,
          params: req.params,
          headers: req.headers.merge(
            'Expect' => '',
            'Transfer-Encoding' => ''
          ),
          body: req.body

        request.on_complete do |response|
          if response.timed_out?
            raise ::Acfs::TimeoutError.new(req)
          elsif response.code.zero?
            # Failed to get HTTP response
            raise ::Acfs::RequestError.new(req, response.return_message)
          else
            req.complete! convert_response(req, response)
          end
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
