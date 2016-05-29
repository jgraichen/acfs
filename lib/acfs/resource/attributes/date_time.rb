module Acfs::Resource::Attributes
  # @api public
  #
  # DateTime attribute type. Use it in your model as
  # an attribute type:
  #
  # @example
  #   class User < Acfs::Resource
  #     attribute :name, :date_time
  #   end
  #
  class DateTime < Base

    # @api public
    #
    # Cast given object to DateTime.
    #
    # @param [Object] value Object to cast.
    # @return [DateTime] Casted object as DateTime.
    #
    def cast_value(value)
      if value.blank?
        nil
      elsif value.acts_like?(:time) || value.acts_like?(:date)
        value.to_datetime
      else
        ::DateTime.iso8601 value
      end
    end
  end
end
