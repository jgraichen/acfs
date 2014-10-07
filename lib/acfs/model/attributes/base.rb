module Acfs::Model::Attributes

  class Base
    attr_reader :options

    def initialize(opts = {})
      @options = opts
      @options.reverse_merge! allow_nil: true

      if options.key?(:default) && optional?
        raise ArgumentError.new 'Optional attributes cannot have a default value.'
      end
    end

    def nil_allowed?
      !!options[:allow_nil]
    end

    def blank_allowed?
      !!options[:allow_blank]
    end

    def default_value
      options[:default].is_a?(Proc) ? options[:default] : cast(options[:default])
    end

    def optional?
      options.fetch(:optional, false)
    end

    def cast(obj)
      return nil if obj.nil? && nil_allowed? || (obj == '' && blank_allowed?)
      cast_type obj
    end

    def cast_type(obj)
      raise NotImplementedError
    end
  end
end
