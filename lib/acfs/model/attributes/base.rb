module Acfs::Model::Attributes

  class Base
    attr_reader :options

    def initialize(opts = {})
      @options = opts
    end

    def allow_nil?
      !!options[:allow_nil]
    end
    alias_method :nil_allowed?, :allow_nil?

    def default_value
      options[:default]
    end
  end
end
