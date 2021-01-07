# frozen_string_literal: true

module Acfs
  # @api private
  #
  # Describes a CRUD operation. Handle request creation and response
  # processing as well as error handling and stubbing.
  #
  class Operation
    attr_reader :action, :params, :resource, :data, :callback, :location, :url

    delegate :service, to: :resource
    delegate :call, to: :callback

    def initialize(resource, action, **opts, &block)
      @resource = resource
      @action   = action.to_sym

      # Operations can be delayed so dup params and data to avoid
      # later in-place changes by modifying passed hash
      @params   = (opts[:params] || {}).dup
      @data     = (opts[:data]   || {}).dup

      unless (@url = opts[:url])
        @location = resource.location(action: @action).extract_from(@params, @data)
        @url      = location.str
      end

      @callback = block
    end

    def single?
      %i[read update delete].include? action
    end

    def synchronous?
      %i[update delete create].include? action
    end

    def id
      # TODO
      @id ||= params.delete(:id) || data[:id]
    end

    def full_params
      (id ? params.merge(id: id) : params).merge(location_vars)
    end

    def location_vars
      location ? location.vars : {}
    end

    def method
      {read: :get, list: :get, update: :put, create: :post, delete: :delete}[action]
    end

    def request
      request = ::Acfs::Request.new url, method: method, params: params,
                                         data: data, operation: self
      request.on_complete do |response|
        ::ActiveSupport::Notifications.instrument 'acfs.operation.complete',
          operation: self,
          response: response

        handle_failure response unless response.success?
        callback.call response.data, response
      end
      request
    end

    def handle_failure(response)
      case response.code
        when 400
          raise ::Acfs::BadRequest.new response: response
        when 401
          raise ::Acfs::Unauthorized.new response: response
        when 403
          raise ::Acfs::Forbidden.new response: response
        when 404
          raise ::Acfs::ResourceNotFound.new response: response
        when 422
          raise ::Acfs::InvalidResource.new response: response, errors: response.data.try(:[], 'errors')
        when 500
          raise ::Acfs::ServerError.new response: response
        when 502
          raise ::Acfs::BadGateway.new response: response
        when 503
          raise ::Acfs::ServiceUnavailable.new response: response
        when 504
          raise ::Acfs::GatewayTimeout.new response: response
        else
          raise ::Acfs::ErroneousResponse.new response: response
      end
    end
  end
end
