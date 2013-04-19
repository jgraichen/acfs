module Acfs
  class Request

    # Module containing callback handling for Requests.
    # Current the only callback type is `on_complete`:
    #
    #   request = Request.new 'URL'
    #   request.on_complete { |response| ... }
    #
    module Callbacks

      # Add a new `on_complete` callback for this request.
      #
      # @example Set on_complete.
      #   request.on_complete { |response| print response.body }
      #
      # @param [ Block ] block The callback block to execute.
      #
      # @yield [ Acfs::Response ]
      #
      # @return [ Acfs::Request ] The request itself.
      #
      def on_complete(&block)
        callbacks.insert 0, block if block_given?
        self
      end

      # Return array of all callbacks.
      #
      # @return [ Array<Block> ] All callbacks.
      #
      def callbacks
        @callbacks ||= []
      end

      # Trigger all callback for given response.
      #
      # @return [ Acfs::Request ] The request itself.
      #
      def complete!(response)
        call_callback response, 0
        self
      end

      private
      def call_callback(res, index)
        callbacks[index].call res, proc { |res| call_callback res, index + 1 } if index < callbacks.size
      end
    end
  end
end
