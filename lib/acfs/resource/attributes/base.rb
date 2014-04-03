module Acfs::Resource::Attributes

  #
  class Base
    attr_reader :options

    def initialize(opts = {})
      @options = opts
      @options.reverse_merge! allow_nil: true
    end

    def nil_allowed?
      options[:allow_nil]
    end

    def blank_allowed?
      options[:allow_blank]
    end

    def default_value
      if options[:default].is_a? Proc
        options[:default]
      else
        cast options[:default]
      end
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
