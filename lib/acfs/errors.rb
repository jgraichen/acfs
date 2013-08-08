module Acfs

  # Acfs base error.
  #
  class Error < StandardError
  end

  # Response error containing the responsible response object.
  #
  class ErroneousResponse < Error
    attr_accessor :response

    def initialize(data = {})
      self.response = data[:response]
      message = ''
      message << "Received erroneous response: #{response.code}"
      if response.data
        message << "\n  with content:\n    "
        message << response.data.map{|k,v| "#{k.inspect}: #{v.inspect}"}.join("\n    ")
      end
      if response.headers.any?
        message << "\n  with headers:\n    "
        message << response.headers.map{|k,v| "#{k}: #{v}"}.join("\n    ")
      end
      message << "\nbased on request: #{response.request.method.upcase} #{response.request.url} #{response.request.format}"
      if response.request.data
        message << "\n  with content:\n    "
        message << response.request.data.map{|k,v| "#{k.inspect}: #{v.inspect}"}.join("\n    ")
      end
      if response.request.headers.any?
        message << "\n  with headers:\n    "
        message << response.request.headers.map{|k,v| "#{k}: #{v}"}.join("\n    ")
      end
      super message
    end
  end

  class AmbiguousStubError < Error
    attr_reader :stubs, :operation

    def initialize(stubs, operation)
      @stubs     = stubs
      @operation = operation

      super 'Ambiguous stubs.'
    end

  end

  # Resource not found error raised on a 404 response
  #
  class ResourceNotFound < ErroneousResponse
  end

  class InvalidResource < ErroneousResponse
    attr_accessor :errors

    def initialize(data)
      self.errors = data[:errors]
      super
    end
  end

  class RealRequestsNotAllowedError < StandardError; end
end
