module Acfs

  # Acfs SingletonResources
  #
  # Usage explanation:
  #   Single.find      => sends GET    request to http://service:port/single
  #   my_single.save   => sends POST   request to http://service:port/single if my_single is a new object
  #                    or sends PUT    request to http://service:port/single if my_single has been requested before
  #   my_single.delete => sends DELETE request to http://service:port/single
  #
  # SingletonResources do not support the Resource method :all, since
  # always only a single instance of the resource is being returned
  #
  class SingletonResource < Acfs::Resource

    # @api public
    #
    # Return true if model is a new record and was not saved yet.
    #
    # Checks weather object is loaded via delegator or not, since
    # the id-attribute is not required for singletons this check
    # cannot check for existence of value in id-attribute
    #
    # @return [Boolean] True if resource is newly created, false otherwise.
    #
    def new?
      ! (@loaded.present? && @loaded)
    end
    alias :new_record? :new?

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
    def delete!(opts = {})
      opts[:params] ||= {}

      operation :delete, opts do |data|
        update_with data
        freeze
      end
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
      #   @yield [ resource ] Callback block to be executed after resource was fetched successfully.
      #   @yieldparam resource [ self ] Fetched resources.
      #
      #   @return [ self ] Resource object.
      #
      def find(*attrs, &block)
        opts = { params: attrs.extract_options! }

        model = ResourceDelegator.new self.new

        operation :read, opts do |data|
          model.__setobj__ create_resource data, origin: model.__getobj__
          block.call model unless block.nil?
        end

        model
      end

      # @api public
      #
      # Undefined, raises NoMethodError.
      # A singleton always only returns one object, therefore the
      # methods :all and :where are not defined.
      #
      undef_method :all
      undef_method :where
    end
  end
end
