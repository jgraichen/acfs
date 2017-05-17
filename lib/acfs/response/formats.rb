require 'action_dispatch'

module Acfs
  class Response
    # Quick accessors for format handling.
    module Formats
      def content_type
        @content_type ||= read_content_type
      end

      def json?
        content_type == Mime[:json]
      end

      private

      def read_content_type
        return 'text/plain' unless headers && headers['Content-Type']

        content_type = headers['Content-Type'].split(/;\s*\w+="?\w+"?/).first
        Mime::Type.parse(content_type).first
      end
    end
  end
end
