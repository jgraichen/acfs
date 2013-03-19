require 'active_support/core_ext/class/attribute_accessors'

module Acfs
  module Client
    def self.included(base)
      base.class_eval do
        cattr_accessor :base_url
      end
    end

    def initialize

    end
  end
end
