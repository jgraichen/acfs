module Acfs::Model::Attributes

  # @api public
  #
  # Float attribute type. Use it in your model as an attribute type:
  #
  # @example
  #   class User
  #     include Acfs::Model
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
    def cast(obj)
      obj.to_f
    end
  end
end
