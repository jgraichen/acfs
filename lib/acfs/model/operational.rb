module Acfs::Model

  # Provide methods for creating and processing CRUD operations and
  # handling responses. That includes error handling as well as
  # handling stubbed resources.
  #
  # Should only be used internal.
  #
  module Operational
    extend ActiveSupport::Concern
    delegate :operation, to: :class

    module ClassMethods
      def operation(action, opts = {}, &block)
        Operation.new(self, action, opts, &block).build
      end
    end

    class Operation
      attr_reader :action, :params, :resource, :data, :callback
      delegate :service, to: :resource

      def initialize(resource, action, opts = {}, &block)
        @resource = resource
        @action   = action.to_sym
        @params   = opts[:params] || {}
        @data     = opts[:data]   || {}
        @callback = block
      end

      def build
        synchronous? ? service.run(request) : service.queue(request)
      end

      def single?
        [:read, :update, :delete].include? action
      end

      def synchronous?
        [:update, :delete, :create].include? action
      end

      def id
        @id ||= params.delete(:id) || data[:id]
      end

      def url
        if single?
          raise ArgumentError, 'ID parameter required for READ, UPDATE and DELETE operation.' unless id
          resource.url id
        else
          resource.url
        end
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
            raise ::Acfs::InvalidResource.new response: response, errors: response.data['errors']
          else
            raise ::Acfs::ErroneousResponse.new response: response
        end
      end
    end
  end
end
