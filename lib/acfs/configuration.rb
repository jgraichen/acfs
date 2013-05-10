require 'uri'

module Acfs

  #
  #
  class Configuration
    attr_reader :locations

    def initialize
      @locations = {}
    end

    def configure(&block)
      if block.arity > 0
        block.call self
      else
        instance_eval &block
      end
    end

    def locate(service, uri = nil)
      service = service.to_s.underscore.to_sym
      if uri.nil?
        locations[service]
      else
        locations[service] = URI.parse uri
      end
    end

    class << self

      def current
        @configuration ||= new
      end

      def set(configuration)
        @configuration = configuration if configuration.is_a? Configuration
      end
    end
  end
end
