module Acfs
  module Model

    # Thin wrapper around ActiveModel::Dirty
    #
    module Dirty
      extend ActiveSupport::Concern
      include ActiveModel::Dirty

      # @api private
      #
      # Resets all changes. Does not touch previous changes.
      #
      def reset_changes
        changed_attributes.clear
      end

      # @api private
      #
      # Save current changes as previous changes and reset
      # current one.
      #
      def swap_changes
        @previously_changed = changes
        reset_changes
      end

      # @api private
      #
      def save!(*)
        super.tap { |_| swap_changes }
      end

      # @api private
      #
      def loaded!
        reset_changes
        super
      end

      # @api private
      #
      def write_raw_attribute(name, value, opts = {}) # :nodoc:
        attribute_will_change! name if opts[:change].nil? or opts[:change]
        super
      end
    end
  end
end
