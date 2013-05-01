module Acfs
  module Model

    # Allow to track the persistence state of a model.
    #
    module Persistence
      extend ActiveSupport::Concern

      # Check if the model is persisted. A model is persisted if
      # it is saved after beeing created or when it was not changed
      # since it was loaded.
      #
      # user = User.new name: "John"
      # user.persisted? # => false
      # user.save
      # user.persisted? # => true
      #
      # user2 = User.find 5
      # user2.persisted? # => true
      # user2.name = 'Amy'
      # user2.persisted? # => false
      # user2.save
      # user2.persisted? # => true
      #
      def persisted?
        !new? && !changed?
      end

      # Return true if model is a new record and was not saved yet.
      #
      def new?
        read_attribute(:id).nil?
      end
      alias :new_record? :new?

      # Save the resource.
      #
      # It will PATCH to the service to update the resource or send
      # a POST to create a new one if the resource is new.
      #
      # `#save` return true of operation was successful, otherwise false.
      #
      def save(*args)
        save! *args
        true
      rescue Acfs::Error
        false
      end

      def save!(opts = {}) # :nodoc:
        #raise ::Acfs::InvalidResource errors: errors.to_a unless valid?

        opts[:data] = attributes unless opts[:data]

        request = new? ? create_request(opts) : put_request(opts)
        request.on_complete do |response|
          if response.success?
            update_with response.data
          else
            self.class.raise! response
          end
        end

        self.class.service.run request
      end

      module ClassMethods

        # Create a new resource sending given data. If resource cannot be
        # created an error will be thrown.
        #
        def create!(data, opts = {})
          new.tap do |model|
            model.save! opts.merge data: data
          end
        end

        # Create a new resource sending given data. If resource cannot be
        # create model will be returned and error hash contains response
        # errors if available.
        #
        def create(data, opts = {})
          model = new
          model.save! opts.merge data: data
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

      def create_request(opts = {})
        Acfs::Request.new self.class.url, method: :post, data: opts[:data]
      end

      def put_request(opts = {})
        Acfs::Request.new url, method: :put, data: opts[:data]
      end
    end
  end
end
