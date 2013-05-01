module Acfs
  class Response

    # Method to fetch information about response status.
    #
    module Status

      # Return response status code. Will return zero if
      # request was not executed or failed on client side.
      #
      def status_code
        return @status.to_i if defined? :@status
        #return response.response_code unless response.nil?
        #0
      end
      alias :code :status_code

      # Return true if response was successful indicated by
      # response status code.
      #
      def success?
        code >= 200 && code < 300
      end

      # Return true unless response status code indicates that
      # resource was not modified according to send precondition headers.
      #
      def modified?
        code != 304
      end
    end
  end
end
