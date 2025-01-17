# frozen_string_literal: true

module Acfs
  # Acfs SingletonResources
  #
  # Usage explanation:
  #   Single.find      => sends GET    request to http://service:port/single
  #   my_single.save   => sends POST   request to http://service:port/single
  #                                    if my_single is a new object
  #                    or sends PUT    request to http://service:port/single
  #                                    if my_single has been requested before
  #   my_single.delete => sends DELETE request to http://service:port/single
  #
  # SingletonResources do not support the Resource method :all, since
  # always only a single instance of the resource is being returned
  #
  class SingletonResource < Acfs::Resource
    # @api public
    #
    # Destroy resource by sending a DELETE request.
    # Will raise an error in case something goes wrong.
    #
    # Deleting a resource is a synchronous operation.
    #
    # @raise [Acfs::ErroneousResponse]
    #   If remote service respond with not successful response.
    # @return [undefined]
    # @see #delete
    #
    def delete!(**opts)
      opts[:params] ||= {}

      operation(:delete, **opts) do |data|
        update_with data
        freeze
      end
    end

    # @api private
    def need_primary_key?
      false
    end

    class << self
      # @api public
      #
      # @overload find(id, opts = {})
      #   Find a singleton resource, optionally with params.
      #
      #   @example
      #     single = Singleton.find # Will query `http://base.url/singletons/`
      #
      #   @param [ Hash ] opts Additional options.
      #   @option opts [ Hash ] :params Additional parameters added to request.
      #
      #   @yield [ resource ] Callback block to be executed after
      #     resource was fetched successfully.
      #   @yieldparam resource [ self ] Fetched resources.
      #
      #   @return [ self ] Resource object.
      #
      def find(*attrs, &)
        find_single(nil, params: attrs.extract_options!, &)
      end

      # @api public
      #
      # Undefined, raises NoMethodError.
      # A singleton always only returns one object, therefore the
      # methods :all and :where are not defined.
      # :find_by is not defined on singletons, use :find instead
      #
      def all
        raise ::Acfs::UnsupportedOperation.new
      end
      alias find_by all
      alias find_by! all

      # @api private
      def location_default_path(_, path)
        path
      end
    end
  end
end
