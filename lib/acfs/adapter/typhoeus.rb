# frozen_string_literal: true

require 'typhoeus'

module Acfs
  module Adapter
    DEFAULT_OPTIONS = {
      tcp_keepalive: true,
      tcp_keepidle: 5,
      tcp_keepintvl: 5
    }.freeze

    # Adapter for Typhoeus.
    #
    class Typhoeus < Base
      def initialize(opts: {}, **kwargs)
        @opts = DEFAULT_OPTIONS.merge(opts)
        @kwargs = kwargs
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
        @hydra ||= ::Typhoeus::Hydra.new(**@kwargs)
      end

      def convert_request(req)
        opts = {
          method: req.method,
          params: req.params,
          headers: req.headers.merge(
            'Expect' => '',
            'Transfer-Encoding' => ''
          ),
          body: req.body
        }

        request = ::Typhoeus::Request.new(req.url, **@opts.merge(opts))

        request.on_complete do |response|
          raise ::Acfs::TimeoutError.new(req) if response.timed_out?

          if response.code.zero?
            # Failed to get HTTP response
            raise ::Acfs::RequestError.new(req, response.return_message)
          end

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
