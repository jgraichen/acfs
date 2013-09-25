module Acfs::Model::Attributes

  # @api public
  #
  # DateTime attribute type. Use it in your model as an attribute type:
  #
  # @example
  #   class User
  #     include Acfs::Model
  #     attribute :name, :date_time
  #   end
  #
  class DateTime < Base

    # @api public
    #
    # Cast given object to DateTime.
    # Expect
    #
    # @param [Object] obj Object to cast.
    # @return [DateTime] Casted object as DateTime.
    #
    def cast(obj)
      return nil if nil_allowed? and obj.blank?
      return obj if obj.is_a? ::DateTime
      return ::DateTime.iso8601(obj.iso8601) if obj.is_a? Time or obj.is_a? Date
      return ::DateTime.iso8601(obj)
    end
  end
end
