# frozen_string_literal: true

module Acfs::Resource::Attributes
  # @api public
  #
  # UUID attribute type. Use it in your model as an attribute type:
  #
  # @example
  #   class User < Acfs::Resource
  #     attribute :id, :uuid
  #   end
  #
  class UUID < Base
    UUID_REGEXP = /[0-9a-f]{8}(-[0-9a-f]{4}){3}-[0-9a-f]{12}/i

    # @api public
    #
    # Check if given object looks like a UUID, eg:
    #   `450b7a40-94ad-11e3-baa8-0800200c9a66`
    # Valid UUIDs are 16 byte numbers represented as
    #  a hexadecimal string in five sub-groups seperated
    #  by a dash. Each group has to consist of a fixed
    #  number of hexadecimal digits:
    #   | Group | Digits |
    #   | -----:|:------ |
    #   |     1 | 8      |
    #   |     2 | 4      |
    #   |     3 | 4      |
    #   |     4 | 4      |
    #   |     5 | 12     |
    #
    # @param [Object] value Object to cast.
    # @return [String] Casted object as UUID.
    #
    def cast_value(value)
      if value.blank?
        nil
      elsif UUID_REGEXP.match?(value.to_s)
        value
      else
        raise TypeError.new "Invalid UUID: `#{value}'"
      end
    end
  end

  # Lower-case alias for automatic type lookup
  Uuid = UUID
end
