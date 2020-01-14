# frozen_string_literal: true

module Acfs
  class Service
    module Middleware
      class Stack
        include Enumerable

        MUTEX = Mutex.new
        IDENTITY = ->(i) { i }

        attr_reader :middlewares

        def initialize
          @middlewares = []
        end

        def call(request)
          build! unless @app

          @app.call request
        end

        def build!
          return if @app

          MUTEX.synchronize do
            return if @app

            @app = build
          end
        end

        def build(app = IDENTITY)
          middlewares.reverse.inject(app) do |next_middleware, current_middleware|
            klass, args, block = current_middleware
            args ||= []

            if klass.is_a?(Class)
              klass.new(next_middleware, *args, &block)
            elsif klass.respond_to?(:call)
              lambda do |env|
                next_middleware.call(klass.call(env, *args))
              end
            else
              raise "Invalid middleware, doesn't respond to `call`: #{klass.inspect}"
            end
          end
        end

        def insert(index, klass, *args, &block)
          middlewares.insert(index, [klass, args, block])
        end

        def each
          middlewares.each {|x| yield x.first }
        end

        def clear
          middlewares.clear
        end
      end
    end
  end
end
