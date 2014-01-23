module Acfs

  # Global Acfs module methods.
  #
  module Global

    # @api private
    # @return [Runner]
    #
    def runner
      @runner ||= Runner.new Adapter::Typhoeus.new
    end

    # @api public
    #
    # Run all queued operations.
    #
    # @return [undefined]
    #
    def run
      runner.start
    end

    # @api public
    #
    # Configure acfs using given block.
    #
    # @return [undefined]
    # @see Configuration#configure
    #
    def configure(&block)
      Configuration.current.configure &block
    end

    # @api public
    #
    # Reset all queues, stubs and internal state.
    #
    def reset
      self.runner.clear
      Acfs::Stub.clear
    end
  end
end
