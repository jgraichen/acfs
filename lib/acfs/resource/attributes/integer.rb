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
    # @param [Object] obj Object to cast.
    # @return [Fixnum] Casted object as fixnum.
    #
    def cast_type(obj)
      Integer obj
    end
  end
end
