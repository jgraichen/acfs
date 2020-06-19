# frozen_string_literal: true

module Acfs
  # Acfs base error.
  #
  class Error < StandardError
    def initialize(opts = {}, message = nil)
      opts.merge! message: message if message
      super opts[:message]
    end
  end

  class UnsupportedOperation < StandardError; end

  class RequestError < Error
    attr_reader :request

    def initialize(request, message)
      @request = request

      message = "#{message}: #{request.method.upcase} #{request.url}"

      super message: message
    end
  end

  class TimeoutError < RequestError
    def initialize(request)
      super(request, 'Timeout reached')
    end
  end

  # Response error containing the responsible response object.
  #
  class ErroneousResponse < Error
    attr_reader :response

    def initialize(opts = {})
      @response = opts[:response]

      message = if response
                  (opts[:message] ? opts[:message] + ':' : 'Received') +
                    " #{response.code} for #{response.request.method.upcase}" \
                    " #{response.request.url} #{response.request.format}"
                else
                  opts[:message] || 'Received erroneous response'
                end

      super opts, message
    end
  end

  class AmbiguousStubError < Error
    attr_reader :stubs, :operation

    def initialize(opts = {})
      require 'pp'

      @stubs     = opts.delete :stubs
      @operation = opts.delete :operation

      message = "Ambiguous stubs for #{operation.action} " \
                "on #{operation.resource}.\n" +
                stubs.map {|s| "  #{s.opts.pretty_inspect}" }.join

      super opts, message
    end
  end

  # 400
  class BadRequest < ErroneousResponse; end

  # 401
  class Unauthorized < ErroneousResponse; end

  # 403
  class Forbidden < ErroneousResponse; end

  # 404
  class ResourceNotFound < ErroneousResponse; end

  # 422
  class InvalidResource < ErroneousResponse
    attr_reader :errors, :resource

    def initialize(opts = {})
      @errors   = opts.delete :errors
      @resource = opts.delete :resource

      if @errors.is_a?(Hash)
        opts[:message] ||= @errors.each_pair.map do |k, v|
          @errors.is_a?(Array) ? "#{k}: #{v.join(', ')}" : "#{k}: #{v}"
        end.join ', '
      elsif @errors.is_a?(Array)
        opts[:message] ||= @errors.join ', '
      end

      super
    end
  end

  # 500
  class ServerError < ErroneousResponse; end

  # 502
  class BadGateway < ErroneousResponse; end

  # 503
  class ServiceUnavailable < ErroneousResponse; end

  # 504
  class GatewayTimeout < ErroneousResponse; end

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

  # Gets raised if ressource type is no valid subclass of
  # parent resource. Check if the type is set to the correct
  # Acfs::Resource Name
  class ResourceTypeError < Error
    attr_reader :base_class
    attr_reader :type_name

    def initialize(opts = {})
      @base_class    = opts.delete :base_class
      @type_name     = opts.delete :type_name
      opts[:message] = "Received resource type `#{type_name}` " \
                       "is no subclass of #{base_class}"
      super
    end
  end

  class RealRequestsNotAllowedError < StandardError; end
end
