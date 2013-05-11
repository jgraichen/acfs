require 'uri'
require 'yaml'

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

    def load(filename)
      config = YAML::load File.read filename
      env    = ENV['RACK_ENV'] || ENV['RAILS_ENV'] || 'development'

      config = config[env] if config.has_key? env
      config.each do |key, value|
        case key
          when 'services' then load_services value
        end
      end
    end

    def load_services(services)
      services.each do |service, data|
        if (val = data).is_a?(String) || (val = data['locate'])
          locate service.to_sym, val
        end
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
