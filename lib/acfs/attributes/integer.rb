module Acfs::Attributes

  # Integer attribute type. Use it in your model as an attribute type:
  #
  #   class User
  #     attribute :name, :integer
  #   end
  #
  module Integer # :nodoc:

    def self.cast(obj)
      obj.to_i
    end
  end
end
