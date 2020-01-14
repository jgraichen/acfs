# frozen_string_literal: true

module Acfs::Resource::Attributes
  # @api public
  #
  # String attribute type. Use it in your model as
  # an attribute type:
  #
  # @example
  #   class User < Acfs::Resource
  #     attribute :name, :string
  #   end
  #
  class String < Base
    # @api public
    #
    # Cast given object to string.
    #
    # @param [Object] value Object to cast.
    # @return [String] Casted string.
    #
    def cast_value(value)
      value.to_s
    end
  end
end
