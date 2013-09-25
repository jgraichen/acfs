module Acfs::Model::Attributes

  class Base
    attr_reader :options

    def initialize(opts = {})
      @options = opts
      @options.reverse_merge! allow_nil: true
    end

    def nil_allowed?
      !!options[:allow_nil]
    end

    def default_value
      options[:default].is_a?(Proc) ? options[:default] : cast(options[:default])
    end

    def cast(obj)
      return nil if obj.nil? && nil_allowed?
      cast_type obj
    end

    def cast_type(obj)
      raise NotImplementedError
    end
  end
end
