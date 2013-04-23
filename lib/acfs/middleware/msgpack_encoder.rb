require 'msgpack'
require 'action_dispatch'

module Acfs
  module Middleware

    # A middleware to encode request data with Message Pack.
    #
    class MessagePackEncoder < Base

      def call(request)
        request.body = ::MessagePack.dump(request.data)
        request.headers['Content-Type'] = 'application/x-msgpack'

        app.call request
      end
    end
  end
end
