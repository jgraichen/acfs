# frozen_string_literal: true

require 'logger'

module Acfs
  module Middleware
    # Log requests and responses.
    #
    class Logger < Base
      attr_reader :logger

      def initialize(app, **opts)
        super
        @logger = options[:logger] || ::Logger.new($stdout)
      end

      def response(res, nxt)
        logger.info "[ACFS] #{res.request.method.to_s.upcase} #{res.request.url} -> #{res.status}"
        nxt.call res
      end
    end
  end
end
