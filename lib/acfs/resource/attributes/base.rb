# frozen_string_literal: true

module Acfs::Resource::Attributes
  class Base
    attr_reader :default

    def initialize(default: nil)
      @default = default
    end

    def cast(value)
      cast_value(value) unless value.nil?
    end

    def default_value
      if default.respond_to? :call
        default
      else
        cast default
      end
    end

    private

    def cast_value(_value)
      raise NotImplementedError
    end
  end
end
