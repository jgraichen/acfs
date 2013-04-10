module Acfs
  class Response

    # Quick accessors for format handling.
    module Formats

      def json?
        headers['Content-Type'] =~ /application\/json;?/
      end
    end
  end
end
