# frozen_string_literal: true

class Acfs::Resource
  # Provides method to check for loading state of resources.
  # A resource that is created but not yet fetched will be loaded
  # after running {Acfs::Global#run Acfs.run}.
  #
  # @example
  #   user = User.find 5
  #   user.loaded? # => false
  #   Acfs.run
  #   user.loaded? # => true
  #
  module Loadable
    extend ActiveSupport::Concern

    # @api public
    #
    # Check if model is loaded or if request is still queued.
    #
    # @return [Boolean] True if resource is loaded, false otherwise.
    #
    def loaded?
      @loaded.nil? ? false : @loaded
    end

    # @api private
    #
    # Mark model as loaded.
    #
    def loaded!
      @loaded = true
    end
  end
end
