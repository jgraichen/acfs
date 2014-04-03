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
    # @param [Object] obj Object to cast.
    # @return [DateTime] Casted object as DateTime.
    #
    def cast_type(obj)
      if nil_allowed? && obj.blank?
        nil
      elsif obj.is_a? ::DateTime
        obj
      elsif obj.is_a?(Time) || obj.is_a?(Date)
        ::DateTime.iso8601 obj.iso8601
      else
        ::DateTime.iso8601 obj
      end
    end
  end
end
