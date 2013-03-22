module Acfs

  class Request
    attr_accessor :body, :format
    attr_reader :url, :headers, :params, :data

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

    def on_complete(&block)
      @on_complete ||= []

      if block_given?
        @on_complete << block
        return self
      end

      @on_complete
    end

    def complete!(response)
      on_complete.each do |block|
        block.call response
      end

      response
    end
  end
end
