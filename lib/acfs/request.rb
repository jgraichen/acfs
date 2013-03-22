require 'acfs/request/callbacks'

module Acfs

  class Request
    attr_accessor :body, :format
    attr_reader :url, :headers, :params, :data

    include Request::Callbacks

    def initialize(url, options = {})
      @url     = url
      @headers = options.delete(:headers) || {}
      @params  = options.delete(:params) || {}
      @data    = options.delete(:data) || nil
      @format  = options.delete(:format) || :json
    end

    def data?
      !data.nil?
    end
  end
end
