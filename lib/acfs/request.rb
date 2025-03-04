# frozen_string_literal: true

require 'acfs/request/callbacks'

module Acfs
  # Encapsulate all data required to make up a request to the
  # underlaying http library.
  #
  class Request
    attr_accessor :body, :format
    attr_reader :uri, :url, :headers, :params, :data, :method, :operation

    include Request::Callbacks
    def initialize(url, **options, &block)
      @uri = URI.parse(url.to_s).tap do |_url|
        @data    = options.delete(:data) || nil
        @format  = options.delete(:format) || :json
        @headers = options.delete(:headers) || {}
        @params  = options.delete(:params) || {}
        @method  = options.delete(:method) || :get
      end
      @url = @uri.to_s

      @operation = options.delete(:operation) || nil

      on_complete(&block) if block
    end

    def data?
      !data.nil?
    end
  end
end
