# frozen_string_literal: true

module Acfs
  module Telemetry
    class << self
      delegate :in_span, :start_span, to: :tracer

      def tracer
        @tracer ||= OpenTelemetry.tracer_provider.tracer('acfs', Acfs::VERSION.to_s)
      end
    end

    protected

    def tracer
      Acfs::Telemetry.tracer
    end
  end
end
