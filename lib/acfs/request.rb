require 'acfs/request/callbacks'

module Acfs

  # Encapsulate all data required to make up a request to the
  # underlaying http library.
  #
  class Request
    attr_accessor :body, :format
    attr_reader :url, :headers, :params, :data, :method, :operation

    include Request::Callbacks

    def initialize(url, options = {}, &block)
      @url = URI.parse(url.to_s).tap do |url|
        @data    = options.delete(:data) || nil
        @format  = options.delete(:format) || :json
        @headers = options.delete(:headers) || {}
        @params  = options.delete(:params) || {}
        @method  = options.delete(:method) || :get
      end.to_s
      @operation = options.delete(:operation) || nil
      on_complete &block if block_given?
    end

    def data?
      !data.nil?
    end

    class << self
      def new(*attrs)
        return attrs[0] if attrs[0].is_a? self
        super
      end
    end
  end
end
