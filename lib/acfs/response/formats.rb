require 'action_dispatch'

module Acfs
  class Response

    # Quick accessors for format handling.
    module Formats

      def mime_type
        @mime_type ||= begin
          content_type = headers['Content-Type'].split(/;\s*\w+="?\w+"?/).first
          Mime::Type.parse(content_type).first
        end
      end

      def json?
        mime_type == Mime::JSON
      end
    end
  end
end
