module Acfs::Resource::Attributes

  # @api public
  #
  # Symbol attribute type. Use it in your model as
  # an attribute type:
  #
  # @example
  #   class User < Acfs::Resource
  #     attribute :special, :symbol
  #   end
  #
  class Symbol < Base

    # @api public
    #
    # Cast given object to symbol.
    #
    # @param [Object] obj Object to cast.
    # @return [Symbol] Casted symbol.
    #
    def cast_type(obj)
      obj.to_sym
    end
  end
end
