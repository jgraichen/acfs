module Acfs::Resource::Attributes
  # @api public
  #
  # Dict attribute type. Use it in your model as an attribute type:
  #
  # @example
  #   class User
  #     include Acfs::Model
  #     attribute :opts, :dict
  #   end
  #
  class Dict < Base
    # @api public
    #
    # Cast given object to a dict/hash.
    #
    # @param [Object] obj Object to cast.
    # @return [Hash] Casted object as hash.
    # @raise [TypeError] If object cannot be casted to a hash.
    #
    def cast_type(obj)
      return obj if obj.is_a? Hash
      return obj.to_h if obj.respond_to? :to_h
      raise TypeError.new "Cannot cast #{obj.inspect} to hash."
    end
  end
end
