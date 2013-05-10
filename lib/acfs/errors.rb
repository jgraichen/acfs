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
