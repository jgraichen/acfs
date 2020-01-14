# frozen_string_literal: true

module Acfs::Resource::Attributes
  # @api public
  #
  # Float attribute type. Use it in your model as an attribute type:
  #
  # @example
  #   class User < Acfs::Resource
  #     attribute :name, :float
  #   end
  #
  class Float < Base
    # @api public
    #
    # Cast given object to float.
    #
    # @param [Object] value Object to cast.
    # @return [Float] Casted object as float.
    #
    def cast_value(value)
      return 0.0 if value.blank?

      case value
        when ::Float then value
        when 'Infinity' then ::Float::INFINITY
        when '-Infinity' then -::Float::INFINITY
        when 'NaN' then ::Float::NAN
        else Float(value)
      end
    end
  end
end
