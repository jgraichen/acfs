# frozen_string_literal: true

class Acfs::Resource
  #
  # Thin wrapper around ActiveModel::Dirty
  #
  module Dirty
    extend ActiveSupport::Concern
    include ActiveModel::Dirty

    # @api private
    #
    def reset_changes
      clear_changes_information
    end

    # @api private
    #
    def save!(**kwargs)
      super.tap {|_| changes_applied }
    end

    # @api private
    #
    def loaded!
      reset_changes
      super
    end

    # @api private
    #
    def write_raw_attribute(name, value, opts = {})
      attribute_will_change!(name) if opts[:change].nil? || opts[:change]
      super
    end
  end
end
