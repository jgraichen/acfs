module Acfs

  # Global Acfs module methods.
  #
  module Global

    def runner
      @runner ||= Runner.new Adapter::Typhoeus.new
    end

    # Run all queued operations.
    #
    def run
      runner.start
    end
  end
end
