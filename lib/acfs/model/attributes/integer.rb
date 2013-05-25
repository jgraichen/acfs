module Acfs::Model
  module Attributes

    # @api public
    #
    # Integer attribute type. Use it in your model as an attribute type:
    #
    # @example
    #   class User
    #     include Acfs::Model
    #     attribute :name, :integer
    #   end
    #
    module Integer

      # @api public
      #
      # Cast given object to integer.
      #
      # @param [Object] obj Object to cast.
      # @return [Fixnum] Casted object as fixnum.
      #
      def self.cast(obj)
        obj.to_i
      end
    end
  end
end
