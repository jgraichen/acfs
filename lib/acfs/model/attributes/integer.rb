module Acfs::Model
  module Attributes

    # Integer attribute type. Use it in your model as an attribute type:
    #
    #   class User
    #     include Acfs::Model
    #     attribute :name, :integer
    #   end
    #
    module Integer # :nodoc:

      def self.cast(obj)
        obj.to_i
      end
    end
  end
end
