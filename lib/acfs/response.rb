module Acfs

  # This represents a response. In addition to an standard HTTP
  # it has a field `data` for storing the encoded body.
  #
  class Response
    attr_accessor :data
    attr_reader :request, :status, :headers, :body

    include Formats

    def initialize(request, status = 200, headers = {}, body = nil)
      @request = request
      @status  = status
      @headers = headers
      @body    = body
    end
  end
end
