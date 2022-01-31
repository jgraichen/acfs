# frozen_string_literal: true

class Acfs::Resource
  # @api private
  #
  # Provide methods for creating and processing CRUD operations and
  # handling responses. That includes error handling as well as
  # handling stubbed resources.
  #
  # Should only be used internal.
  #
  module Operational
    extend ActiveSupport::Concern

    def operation(...)
      self.class.operation(...)
    end

    module ClassMethods
      # Invoke CRUD operation.
      def operation(action, **opts, &block)
        Acfs.runner.process ::Acfs::Operation.new(self, action, **opts, &block)
      end
    end
  end
end
