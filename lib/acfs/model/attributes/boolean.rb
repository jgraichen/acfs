module Acfs::Model
  module Attributes

    # Boolean attribute type. Use it in your model as an attribute type:
    #
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
    module Boolean # :nodoc:

      TRUE_VALUES = %w(true on yes)

      def self.cast(obj)
        return true if obj.is_a? TrueClass
        return false if obj.is_a? FalseClass

        TRUE_VALUES.include? obj.to_s
      end
    end
  end
end
