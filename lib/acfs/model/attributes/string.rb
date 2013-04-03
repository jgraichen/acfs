module Acfs::Model
  module Attributes

    # String attribute type. Use it in your model as an attribute type:
    #
    #   class User
    #     include Acfs::Model
    #     attribute :name, :string
    #   end
    #
    module String # :nodoc:

      def self.cast(obj)
        obj.to_s
      end
    end
  end
end
