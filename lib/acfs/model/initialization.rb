module Acfs::Model

  # Initialization drop-in for pre-4.0 ActiveModel.
  #
  module Initialization

    # @api public
    #
    # Initializes a new model with the given `params`.
    #
    # @example
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
    # @param [ Hash{ Symbol => Object } ] params Attributes to set on resource.
    #
    def initialize(params = {})
      params.each do |attr, value|
        self.public_send("#{attr}=", value)
      end if params
    end

  end
end
