module Acfs::Resource::Attributes
  # @api public
  #
  # List attribute type. Use it in your model as an attribute type:
  #
  # @example
  #   class User < Acfs::Resource
  #     attribute :name, :list
  #   end
  #
  class List < Base
    # @api public
    #
    # Cast given object to a list.
    #
    # @param [Object] value Object to cast.
    # @return [Fixnum] Casted object as list.
    # @raise [TypeError] If object cannot be casted to a list.
    #
    def cast_value(value)
      return nil if value.blank?

      if value.is_a?(::Array)
        value
      elsif value.respond_to?(:to_ary)
        value.to_ary
      elsif value.respond_to?(:to_a)
        value.to_a
      else
        Array(value)
      end
    end
  end
end
