module Acfs
  module Model

    # Thin wrapper around ActiveModel::Dirty
    #
    module Dirty
      extend ActiveSupport::Concern
      include ActiveModel::Dirty

      # Resets all changes. Do not touch previous changes.
      #
      def reset_changes
        changed_attributes.clear
      end

      # Save current changes as previous changes and reset
      # current one.
      #
      def swap_changes
        @previously_changed = changes
        reset_changes
      end

      def save!(*_) # :nodoc:
        super.tap { |__| swap_changes }
      end

      def loaded! # :nodoc:
        reset_changes
        super
      end

      def write_raw_attribute(name, value, opts = {}) # :nodoc:
        attribute_will_change! name if opts[:change].nil? or opts[:change]
        super
      end
    end
  end
end
