module Acfs

  # A wrapper for collection of resources providing
  # methods to access singular or multiple resources.
  #
  class Resource
    attr_reader :name, :options

    def initialize(name, options = {})
      @name    = name
      @options = options
    end

    def find(*attrs)

    end
  end
end
