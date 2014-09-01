module Acfs
  module Middleware

    # A base middleware that does not modify request or response.
    # Can be used as super class for custom middleware implementations.
    #
    class Serializer < Base
      def encode(data)
        raise NotImplementedError
      end

      def decode(data)
        raise NotImplementedError
      end

      def mime
        raise NotImplementedError
      end

      def call(request)
        unless request.headers['Content-Type']
          request.body = encode request.data
          request.headers['Content-Type'] = mime
        end

        accept = request.headers['Accept'].to_s.split(',')
        accept << "#{mime};q=#{options.fetch(:q, 1)}"
        request.headers['Accept'] = accept.join(',')

        request.on_complete do |response, nxt|
          if mime == response.content_type
            response.data = decode response.body
          end

          nxt.call response
        end

        app.call(request)
      end
    end
  end
end