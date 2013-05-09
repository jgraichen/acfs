module Acfs

  # Global Acfs module methods.
  #
  module Global

    # Return request adapter
    #
    def adapter
      @adapter ||= Adapter::Typhoeus.new
    end

    # Run all queued operations.
    #
    def run
      adapter.run
    end
  end
end
