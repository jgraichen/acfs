module Acfs::Model
  module Attributes

    # @api public
    #
    # List attribute type. Use it in your model as an attribute type:
    #
    # @example
    #   class User
    #     include Acfs::Model
    #     attribute :name, :list
    #   end
    #
    module List

      # @api public
      #
      # Cast given object to a list.
      #
      # @param [Object] obj Object to cast.
      # @return [Fixnum] Casted object as list.
      # @raise [TypeError] If object cannot be casted to a list.
      #
      def self.cast(obj)
        return obj.to_a if obj.respond_to? :to_a
        raise TypeError.new "Cannot cast #{obj.inspect} to array."
      end
    end
  end
end
