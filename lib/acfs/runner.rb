# frozen_string_literal: true

require 'acfs/service/middleware'

module Acfs
  # @api private
  #
  class Runner
    include Service::Middleware
    include Acfs::Telemetry

    attr_reader :adapter

    def initialize(adapter)
      @adapter = adapter
      @running = false
    end

    # Process an operation. Synchronous operations will be run
    # and parallel operations will be queued.
    #
    def process(operation)
      ::ActiveSupport::Notifications.instrument('acfs.operation.before_process', operation: operation)
      operation.synchronous? ? run(operation) : enqueue(operation)
    end

    # Run operation right now skipping queue.
    #
    def run(operation)
      tracer.in_span('acfs.runner.sync_run') do
        ::ActiveSupport::Notifications.instrument('acfs.runner.sync_run', operation: operation) do
          operation_request(operation) {|req| adapter.run req }
        end
      end
    end

    # List of current queued operations.
    #
    def queue
      @queue ||= []
    end

    # Enqueue operation to be run later.
    #
    def enqueue(operation)
      tracer.in_span('acfs.runner.enqueue') do
        ::ActiveSupport::Notifications.instrument('acfs.runner.enqueue', operation: operation) do
          if running?
            operation_request(operation) {|req| adapter.queue req }
          else
            queue << operation
          end
        end
      end
    end

    # Return true if queued operations are currently processed.
    #
    def running?
      @running
    end

    # Start processing queued operations.
    #
    def start
      return if running?

      enqueue_operations
      start_all
    rescue StandardError
      queue.clear
      raise
    end

    def clear
      queue.clear
      adapter.abort
      @running = false
    end

    private

    def start_all
      @running = true
      adapter.start
    ensure
      @running = false
    end

    def enqueue_operations
      while (operation = queue.shift)
        operation_request(operation) {|req| adapter.queue req }
      end
    end

    def operation_request(operation)
      return if Acfs::Stub.enabled? && Acfs::Stub.stubbed(operation)

      req = operation.service.prepare(operation.request)
      return unless req.is_a? Acfs::Request

      req = prepare(req)
      return unless req.is_a? Acfs::Request

      yield req
    end

    def prepare(request)
      method = request.method.to_s.upcase
      template = request.operation.location&.raw_uri.to_s

      name = "HTTP #{method}"
      name = "#{method} #{template}" if template

      attributes = {
        'http.request.method' => method,
        'server.address' => request.uri.host,
        'server.port' => request.uri.port,
        'url.full' => request.uri.to_s,
        'url.scheme' => request.uri.scheme,
        'url.template' => template,
      }

      span = tracer.start_span(name, attributes:, kind: :client)
      OpenTelemetry::Trace.with_span(span) do
        OpenTelemetry.propagation.inject(request.headers)

        request.on_complete do |response, nxt|
          span.set_attribute('http.response.status_code', response.status_code)
          span.status = OpenTelemetry::Trace::Status.error unless (100..399).cover?(response.status_code)

          span.finish
          nxt.call(response)
        end

        super
      end
    end
  end
end
