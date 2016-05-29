module Acfs::Resource::Attributes
  # @api public
  #
  # Boolean attribute type. Use it in your model as an attribute type:
  #
  # @example
  #   class User < Acfs::Resource
  #     attribute :name, :boolean
  #   end
  #
  # Given objects will be converted to string. The following strings
  # are considered true, everything else false:
  #
  #  true, on, yes
  #
  class Boolean < Base
    TRUE_VALUES = [true, 1, '1', 'on', 'yes', 'true']

    # @api public
    #
    # Cast given object to boolean.
    #
    # @param [Object] value Object to cast.
    # @return [TrueClass, FalseClass] Casted boolean.
    #
    def cast_value(value)
      TRUE_VALUES.include? value
    end
  end
end
