module Acfs::Model
  module Attributes

    # @api public
    #
    # Boolean attribute type. Use it in your model as an attribute type:
    #
    # @example
    #   class User
    #     include Acfs::Model
    #     attribute :name, :boolean
    #   end
    #
    # Given objects will be converted to string. The following strings
    # are considered true, everything else false:
    #
    #  true, on, yes
    #
    class Boolean < Base

      TRUE_VALUES = %w(true on yes 1)

      # @api public
      #
      # Cast given object to boolean.
      #
      # @param [Object] obj Object to cast.
      # @return [TrueClass, FalseClass] Casted boolean.
      #
      def cast_type(obj)
        return true if obj.is_a? TrueClass
        return false if obj.is_a? FalseClass

        TRUE_VALUES.include? obj.to_s
      end
    end
  end
end
