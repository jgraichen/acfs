# frozen_string_literal: true

require 'logger'

module Acfs
  module Middleware
    # Log requests and responses.
    #
    class Logger < Base
      def initialize(app, options = {})
        super
        @logger = options[:logger] if options[:logger]
      end

      def response(res, nxt)
        logger.info "[ACFS] #{res.request.method.to_s.upcase} #{res.request.url} -> #{res.status}"
        nxt.call res
      end

      def logger
        @logger ||= ::Logger.new STDOUT
      end
    end
  end
end
