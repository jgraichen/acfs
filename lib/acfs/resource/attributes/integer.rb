module Acfs::Resource::Attributes
  # @api public
  #
  # Integer attribute type. Use it in your model as an attribute type:
  #
  # @example
  #   class User < Acfs::Resource
  #     attribute :name, :integer
  #   end
  #
  class Integer < Base
    # @api public
    #
    # Cast given object to integer.
    #
    # @param [Object] value Object to cast.
    # @return [Fixnum] Casted object as fixnum.
    #
    def cast_value(value)
      if value.blank?
        0
      else
        Integer(value)
      end
    end
  end
end
