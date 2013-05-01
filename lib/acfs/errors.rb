module Acfs

  # Acfs base error.
  #
  class Error < StandardError
  end

  # Response error containing the responsible response object.
  #
  class ErroneousResponse < Error
    attr_accessor :response

    def initialize(response)
      self.response = response
    end
  end

  # Resource not found error raised on a 404 response
  #
  class ResourceNotFound < ErroneousResponse
  end

end
