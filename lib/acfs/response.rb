# frozen_string_literal: true

require 'acfs/response/formats'
require 'acfs/response/status'
require 'active_support/core_ext/module/delegation'

module Acfs
  # This represents a response. In addition to an standard HTTP
  # it has a field `data` for storing the encoded body.
  #
  class Response
    attr_accessor :data
    attr_reader :headers, :body, :request, :status

    include Response::Formats
    include Response::Status

    # delegate :status, :status_message, :success?, :modified?, :timed_out?,
    #         :response_body, :response_headers, :response_code, :headers,
    #         to: :response

    def initialize(request, **opts)
      @request  = request
      @status   = opts[:status]  || 0
      @headers  = opts[:headers] || {}
      @body     = opts[:body]    || ''
      @data     = opts[:data]    || nil
    end
  end
end
