module Acfs
  module Model

    # Allow to track the persistence state of a model.
    #
    module Persistence
      extend ActiveSupport::Concern

      # @api public
      #
      # Check if the model is persisted. A model is persisted if
      # it is saved after beeing created or when it was not changed
      # since it was loaded.
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
      #   user2.persisted? # => false
      #   user2.save
      #   user2.persisted? # => true
      #
      # @return [TrueClass, FalseClass] True if resource has no changes and is not newly created, false otherwise.
      #
      def persisted?
        !new? && !changed?
      end

      # @api public
      #
      # Return true if model is a new record and was not saved yet.
      #
      # @return [TrueClass, FalseClass] True if resource is newly created, false otherwise.
      #
      def new?
        read_attribute(:id).nil?
      end
      alias :new_record? :new?

      # @api public
      #
      # Saves the resource.
      #
      # It will PUT to the service to update the resource or send
      # a POST to create a new one if the resource is new.
      #
      # Saving a resource is a synchronous operation.
      #
      # @return [TrueClass, FalseClass] True if save operation was successful, false otherwise.
      # @see #save! See #save! for available options.
      #
      def save(*args)
        save! *args
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
      # @param [Hash] opts Hash with additional options.
      # @option opts [Hash] :data Data to send to remote service. Default will be resource attributes.
      #
      # @raise [Acfs::InvalidResource]
      #   If remote services respond with 422 response. Will fill errors with data from response
      # @raise [Acfs::ErroneousResponse]
      #   If remote service respond with not successful response.
      #
      # @see #save
      #
      def save!(opts = {})
        #raise ::Acfs::InvalidResource errors: errors.to_a unless valid?

        opts[:data] = attributes unless opts[:data]

        operation (new? ? :create : :update), opts do |data|
          update_with data
        end
      end

      # @api public
      #
      # Destroy resource by sending a DELETE request.
      #
      # Deleting a resource is a synchronous operation.
      #
      # @return [TrueClass, FalseClass]
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
      # @return [undefined]
      # @see #delete
      #
      def delete!(opts = {})
        opts[:params] ||= {}
        opts[:params].merge! id: id

        operation :delete, opts do |data|
          update_with data
          freeze
        end
      end

      module ClassMethods

        # @api public
        #
        # Create a new resource sending given data. If resource cannot be
        # created an error will be thrown.
        #
        # Saving a resource is a synchronous operation.
        #
        # @param [Hash{Symbol, String => Object}] data Data to send in create request.
        # @return [self] Newly resource object.
        #
        # @raise [Acfs::InvalidResource]
        #   If remote services respond with 422 response. Will fill errors with data from response
        # @raise [Acfs::ErroneousResponse]
        #   If remote service respond with not successful response.
        #
        # @see Acfs::Model::Persistence#save! Available options. `:data` will be overridden with provided data hash.
        # @see #create
        #
        def create!(data, opts = {})
          new.tap do |model|
            model.save! opts.merge data: data
          end
        end

        # @api public
        #
        # Create a new resource sending given data. If resource cannot be
        # create model will be returned and error hash contains response
        # errors if available.
        #
        # Saving a resource is a synchronous operation.
        #
        # @param [Hash{Symbol, String => Object}] data Data to send in create request.
        # @return [self] Newly resource object.
        #
        # @raise [Acfs::ErroneousResponse]
        #   If remote service respond with not successful response.
        #
        # @see Acfs::Model::Persistence#save! Available options. `:data` will be overridden with provided data hash.
        # @see #create!
        #
        def create(data, opts = {})
          model = new
          model.save! opts.merge data: data
          model
        rescue InvalidResource => err
          (err.errors || []).each do |field, errors|
            model.errors.set field, errors
          end
          model
        end
      end

      private
      def update_with(data)
        self.attributes = data
        loaded!
      end
    end
  end
end
