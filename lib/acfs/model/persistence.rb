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

      def save!(*) # :nodoc:
        request = new? ? create_request : put_request
        request.on_complete do |response|
          update_with response.data
        end

        self.class.service.run request
      end

      module ClassMethods

        # Create a new resource sending given data.
        #
        def create(data, opts = {})
          model = new
          request = Acfs::Request.new url, method: :post, data: data
          request.on_complete do |response|
            model.attributes = response.data
            model.loaded!
          end

          service.run request
          model
        end
      end

      private
      def update_with(data)
        self.attributes = data
        loaded!
      end

      def create_request
        Acfs::Request.new self.class.url, method: :post, data: attributes
      end

      def put_request
        Acfs::Request.new url, method: :put, data: attributes
      end
    end
  end
end
