module Acfs
  module Attributes
    def self.included(base)
      base.class_eval do
        extend ClassMethods
        include InstanceMethods
      end
    end

    module InstanceMethods # :nodoc:

    end

    module ClassMethods # :nodoc:

      def attribute(name, type = nil, opts = {})
        self.attr_accessor name.to_sym
      end
    end
  end
end
