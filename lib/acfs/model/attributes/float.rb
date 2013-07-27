module Acfs::Model
  module Attributes

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
    module Float

      # @api public
      #
      # Cast given object to float.
      #
      # @param [Object] obj Object to cast.
      # @return [Float] Casted object as float.
      #
      def self.cast(obj)
        obj.to_f
      end
    end
  end
end
