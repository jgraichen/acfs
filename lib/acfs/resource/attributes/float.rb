module Acfs::Resource::Attributes

  # @api public
  #
  # Float attribute type. Use it in your model as an attribute type:
  #
  # @example
  #   class User < Acfs::Resource
  #     attribute :name, :float
  #   end
  #
  class Float < Base

    # @api public
    #
    # Cast given object to float.
    #
    # @param [Object] obj Object to cast.
    # @return [Float] Casted object as float.
    #
    def cast_type(obj)
      Float obj
    end
  end
end
