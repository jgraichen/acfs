# frozen_string_literal: true

module Acfs
  module Middleware
    # Print resquests and response on terminal
    #
    class Print < Base
      def call(req)
        puts '-' * 80
        puts req.inspect
        puts '-' * 80

        super
      end

      def response(res)
        puts '-' * 80
        puts res.inspect
        puts '-' * 80
      end
    end
  end
end
