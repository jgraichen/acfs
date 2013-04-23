require 'multi_json'

module Acfs
  module Middleware

    # A middleware to encore request data using JSON.
    #
    class JsonEncoder < Base

      def call(request)
        unless request.method == :get or request.data.nil?
          request.body = ::MultiJson.dump(request.data)
          request.headers['Content-Type'] = 'application/json'
        end

        app.call request
      end
    end
  end
end
