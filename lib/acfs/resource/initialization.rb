# frozen_string_literal: true

class Acfs::Resource
  #
  # Initialization drop-in for pre-4.0 ActiveModel.
  #
  module Initialization
    #
    # @api public
    #
    # Initializes a new model with the given `params`.
    #
    # @example
    #   class User < Acfs::Resource
    #     attribute :name
    #     attribute :email, default: ->{ "#{name}@dom.tld" }
    #     attribute :age, :integer, default: 18
    #   end
    #
    #   user = User.new({name: 'bob'})
    #   user.name  # => "bob"
    #   user.email # => "bob@dom.tld"
    #   user.age   # => 18
    #
    # @param attributes [Hash{Symbol => Object}] Attributes to set on resource.
    #
    def initialize(attributes = {})
      write_attributes(attributes) if attributes
    end
  end
end
