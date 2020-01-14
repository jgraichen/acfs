# frozen_string_literal: true

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
    # @param [Object] value Object to cast.
    # @return [Hash] Casted object as hash.
    # @raise [TypeError] If object cannot be casted to a hash.
    #
    def cast_value(value)
      return {} if value.blank?

      if value.is_a?(Hash)
        value
      elsif value.respond_to?(:serializable_hash)
        value.serializable_hash
      elsif value.respond_to?(:to_hash)
        value.to_hash
      elsif value.respond_to?(:to_h)
        value.to_h
      else
        Hash(value)
      end
    end
  end
end
