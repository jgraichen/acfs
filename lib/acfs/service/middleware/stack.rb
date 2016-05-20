require 'action_dispatch/middleware/stack'

module Acfs
  class Service
    module Middleware
      class Stack < ActionDispatch::MiddlewareStack
        MUTEX = Mutex.new
        IDENTITY = -> (i) { i }

        def build!
          MUTEX.synchronize do
            return if @stack

            @stack = build
          end
        end

        def build(app = IDENTITY)
          super
        end

        def call(request)
          build! unless @stack

          @stack.call request
        end

        def clear
          middlewares.clear
        end
      end
    end
  end
end
