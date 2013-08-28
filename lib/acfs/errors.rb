module Acfs

  # Acfs base error.
  #
  class Error < StandardError
    def initialize(opts = {}, message = nil)
      opts.merge! message: message if message
      super opts[:message]
    end
  end

  # Response error containing the responsible response object.
  #
  class ErroneousResponse < Error
    attr_reader :response

    def initialize(opts = {})
      @response = opts[:response]
      message = 'Received erroneous response'
      if response
        message << ": #{response.code}"
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
      end
      super opts, message
    end
  end

  class AmbiguousStubError < Error
    attr_reader :stubs, :operation

    def initialize(opts = {})
      @stubs     = opts.delete :stubs
      @operation = opts.delete :operation

      super opts, 'Ambiguous stubs.'
    end

  end

  # Resource not found error raised on a 404 response
  #
  class ResourceNotFound < ErroneousResponse
  end

  class InvalidResource < ErroneousResponse
    attr_reader :errors, :resource

    def initialize(opts = {})
      @errors   = opts.delete :errors
      @resource = opts.delete :resource
      super
    end
  end

  # A ResourceNotLoaded error will be thrown when calling some
  # modifing methods on not loaded resources as it is usally
  # unwanted to call e.g. `update_attributes` on a not loaded
  # resource.
  # Correct solution is to first run `Acfs.run` to fetch the
  # resource and then update the resource.
  #
  class ResourceNotLoaded < Error
    attr_reader :resource

    def initialize(opts = {})
      @resource = opts.delete :resource
      super
    end
  end

  class RealRequestsNotAllowedError < StandardError; end
end
