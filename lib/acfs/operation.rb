module Acfs

  # @api private
  #
  # Describes a CRUD operation. Handle request creation and response
  # processing as well as error handling and stubbing.
  #
  class Operation
    attr_reader :action, :params, :resource, :data, :callback
    delegate :service, to: :resource
    delegate :call, to: :callback

    def initialize(resource, action, opts = {}, &block)
      @resource = resource
      @action   = action.to_sym

      # Operations can be delayed so dup params and data to avoid
      # later in-place changes by modifying passed hash
      @params   = (opts[:params] || {}).dup
      @data     = (opts[:data]   || {}).dup

      @callback = block
    end

    def single?
      [:read, :update, :delete].include? action
    end

    def synchronous?
      [:update, :delete, :create].include? action
    end

    def id
      # TODO
      @id ||= params.delete(:id) || data[:id]
    end

    def full_params
      id ? params.merge(id: id) : params
    end

    def url
      single? ? resource.url(id) : resource.url
    end

    def method
      { read: :get, list: :get, update: :put, create: :post, delete: :delete }[action]
    end

    def request
      request = ::Acfs::Request.new url, method: method, params: params, data: data
      request.on_complete do |response|
        handle_failure response unless response.success?
        callback.call response.data
      end
      request
    end

    def handle_failure(response)
      case response.code
        when 404
          raise ::Acfs::ResourceNotFound.new response: response
        when 422
          raise ::Acfs::InvalidResource.new response: response, errors: response.data.try(:[], 'errors')
        else
          raise ::Acfs::ErroneousResponse.new response: response
      end
    end
  end
end
