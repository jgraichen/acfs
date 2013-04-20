module Acfs
  module Model

    # Allow to track the persistence state of a model.
    #
    module Persistent

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
        !!@new
      end

      def initialize(*_) # :nodoc:
        @new = true
        super
      end

      def save!(*_) # :nodoc:
        @new = false
        super
      end

      def loaded! # :nodoc:
        @new = false
        super
      end
    end
  end
end
