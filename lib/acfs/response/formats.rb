require 'action_dispatch'

module Acfs
  class Response

    # Quick accessors for format handling.
    module Formats

      def mime_type
        @mime_type ||= Mime::Type.parse(headers['Content-Type']).first
      end

      def json?
        mime_type == Mime::JSON
      end
    end
  end
end
