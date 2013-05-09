module Acfs::Model

  # Provide methods for creating and processing CRUD operations and
  # handling responses. That includes error handling as well as
  # handling stubbed resources.
  #
  # Should only be used internal.
  #
  module Operational
    extend ActiveSupport::Concern
    delegate :operation, to: :'self.class'

    module ClassMethods
      def operation(action, opts = {}, &block)
        Acfs.adapter.process ::Acfs::Operation.new self, action, opts, &block
      end
    end
  end
end
