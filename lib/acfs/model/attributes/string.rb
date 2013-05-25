module Acfs::Model
  module Attributes

    # @api public
    #
    # String attribute type. Use it in your model as an attribute type:
    #
    # @example
    #   class User
    #     include Acfs::Model
    #     attribute :name, :string
    #   end
    #
    module String

      # @api public
      #
      # Cast given object to string.
      #
      # @param [Object] obj Object to cast.
      # @return [String] Casted string.
      #
      def self.cast(obj)
        obj.to_s
      end
    end
  end
end
