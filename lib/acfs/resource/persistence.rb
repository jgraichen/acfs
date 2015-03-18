class Acfs::Resource
  #
  # Allow to track the persistence state of a model.
  #
  module Persistence
    extend ActiveSupport::Concern

    # @api public
    #
    # Check if the model is persisted. A model is persisted if
    # it is saved after being created
    #
    # @example Newly created resource:
    #   user = User.new name: "John"
    #   user.persisted? # => false
    #   user.save
    #   user.persisted? # => true
    #
    # @example Modified resource:
    #   user2 = User.find 5
    #   user2.persisted? # => true
    #   user2.name = 'Amy'
    #   user2.persisted? # => true
    #   user2.save
    #   user2.persisted? # => true
    #
    # @return [Boolean] True if resource has been saved
    #
    def persisted?
      !new?
    end

    # @api public
    #
    # Return true if model is a new record and was not saved yet.
    #
    # @return [Boolean] True if resource is newly created,
    #   false otherwise.
    #
    def new?
      !loaded?
    end
    alias_method :new_record?, :new?

    # @api public
    #
    # Saves the resource.
    #
    # It will PUT to the service to update the resource or send
    # a POST to create a new one if the resource is new.
    #
    # Saving a resource is a synchronous operation.
    #
    # @return [Boolean] True if save operation was successful,
    #   false otherwise.
    # @see #save! See {#save!} for available options.
    #
    def save(*args)
      save!(*args)
      true
    rescue Acfs::Error
      false
    end

    # @api public
    #
    # Saves the resource. Raises an error if something happens.
    #
    # Saving a resource is a synchronous operation.
    #
    # @param opts [Hash] Hash with additional options.
    # @option opts [Hash] :data Data to send to remote service.
    #   Default will be resource attributes.
    #
    # @raise [Acfs::InvalidResource]
    #   If remote services respond with 422 response. Will fill
    #   errors with data from response
    # @raise [Acfs::ErroneousResponse]
    #   If remote service respond with not successful response.
    #
    # @see #save
    #
    def save!(opts = {})
      opts[:data] = attributes unless opts[:data]

      operation((new? ? :create : :update), opts) do |data|
        update_with data
      end
    rescue ::Acfs::InvalidResource => err
      self.remote_errors = err.errors
      raise err
    end

    # @api public
    #
    # Update attributes with given data and save resource.
    #
    # Saving a resource is a synchronous operation.
    #
    # @param attrs [Hash] Hash with attributes to write.
    # @param opts [Hash] Options passed to `save`.
    #
    # @return [Boolean]
    #   True if save operation was successful, false otherwise.
    #
    # @see #save
    # @see #attributes=
    # @see #update_attributes!
    #
    def update_attributes(attrs, opts = {})
      check_loaded! opts

      self.attributes = attrs
      save opts
    end

    # @api public
    #
    # Update attributes with given data and save resource.
    #
    # Saving a resource is a synchronous operation.
    #
    # @param [Hash] attrs Hash with attributes to write.
    # @param [Hash] opts Options passed to `save!`.
    #
    # @raise [Acfs::InvalidResource]
    #   If remote services respond with 422 response. Will fill
    #   errors with data from response
    #
    # @raise [Acfs::ErroneousResponse]
    #   If remote service respond with not successful response.
    #
    # @see #save!
    # @see #attributes=
    # @see #update_attributes
    #
    def update_attributes!(attrs, opts = {})
      check_loaded! opts

      self.attributes = attrs
      save! opts
    end

    # @api public
    #
    # Destroy resource by sending a DELETE request.
    #
    # Deleting a resource is a synchronous operation.
    #
    # @return [Boolean]
    # @see #delete!
    #
    def delete(opts = {})
      delete! opts
      true
    rescue Acfs::Error
      false
    end

    # @api public
    #
    # Destroy resource by sending a DELETE request.
    # Will raise an error in case something goes wrong.
    #
    # Deleting a resource is a synchronous operation.

    # @raise [Acfs::ErroneousResponse]
    #   If remote service respond with not successful response.
    #
    # @return [undefined]
    # @see #delete
    #
    def delete!(opts = {})
      opts[:params] ||= {}
      opts[:params] = attributes_for_url(:delete).merge opts[:params]

      operation :delete, opts do |data|
        update_with data
        freeze
      end
    end

    private

    def attributes_for_url(action)
      arguments_for_url = self.class.location(action: action).arguments
      attributes.slice(*arguments_for_url)
    end

    module ClassMethods
      # @api public
      #
      # Create a new resource sending given data. If resource cannot be
      # created an error will be thrown.
      #
      # Saving a resource is a synchronous operation.
      #
      # @param data [Hash{Symbol, String => Object}]
      #   Data to send in create request.
      #
      # @return [self] Newly resource object.
      #
      # @raise [Acfs::InvalidResource]
      #   If remote services respond with 422 response. Will fill
      #   errors with data from response
      #
      # @raise [Acfs::ErroneousResponse]
      #   If remote service respond with not successful response.
      #
      # @see Acfs::Model::Persistence#save! Available options. `:data`
      #   will be overridden with provided data hash.
      # @see #create
      #
      def create!(data, _opts = {})
        new(data).tap(&:save!)
      end

      # @api public
      #
      # Create a new resource sending given data. If resource cannot be
      # create model will be returned and error hash contains response
      # errors if available.
      #
      # Saving a resource is a synchronous operation.
      #
      # @param data [Hash{Symbol, String => Object}]
      #   Data to send in create request.
      #
      # @return [self] Newly resource object.
      #
      # @raise [Acfs::ErroneousResponse]
      #   If remote service respond with not successful response.
      #
      # @see Acfs::Model::Persistence#save! Available options. `:data`
      #   will be overridden with provided data hash.
      # @see #create!
      #
      def create(data, _opts = {})
        model = new data
        model.save
        model
      end
    end

    private

    def update_with(data)
      self.attributes = data
      loaded!
    end

    def check_loaded!(opts = {})
      return if loaded? || opts[:force]
      raise ::Acfs::ResourceNotLoaded.new resource: self
    end
  end
end
