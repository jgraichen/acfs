require 'active_model'

module Acfs
  module Model
    def self.included(base)
      base.class_eval do
        extend  ActiveModel::Naming
        extend  ActiveModel::Translation

        include ActiveModel::Dirty
        include ActiveModel::Conversion
        include ActiveModel::Validations
      end
    end

    # Initializes a new model with the given +params+.
    #
    #   class User
    #     include Acfs::Model
    #     attribute :name
    #     attribute :email, default: -> { "#{name}@dom.tld" }
    #     attribute :age, :integer, default: 18
    #   end
    #
    #   user = User.new(name: 'bob')
    #   user.name  # => "bob"
    #   user.email # => "bob@dom.tld"
    #   user.age   # => 18
    #
    def initialize(params={})
      params.each do |attr, value|
        self.public_send("#{attr}=", value)
      end if params
    end

    # Indicates if the model is persisted. Default is +false+.
    #
    #  class User
    #    include Acfs::Model
    #    attribute :name
    #  end
    #
    #  user = User.new(name: 'bob')
    #  user.persisted? # => false
    #
    def persisted?
      false
    end
  end
end
