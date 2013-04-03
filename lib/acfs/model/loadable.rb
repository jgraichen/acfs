module Acfs::Model

  module Loadable
    extend ActiveSupport::Concern

    # Check if model is loaded or if request is still queued.
    #
    def loaded?
      !!@loaded
    end

    # Mark model as loaded.
    #
    def loaded!
      @loaded = true
    end
  end
end
