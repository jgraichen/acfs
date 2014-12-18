require 'uri'
require 'yaml'

module Acfs
  # Acfs configuration is used to locate services and get their base URLs.
  #
  class Configuration
    attr_reader :locations

    # @api private
    def initialize
      @locations = {}
    end

    # @api public
    #
    # Configure using given block. If block accepts zero arguments
    # bock will be evaluated in context of the configuration instance
    # otherwise the configuration instance will be given as first arguments.
    #
    # @yield [configuration] Give configuration as arguments or evaluate block
    #   in context of configuration object.
    # @yieldparam configuration [Configuration] Configuration object.
    # @return [undefined]
    #
    def configure(&block)
      if block.arity > 0
        block.call self
      else
        instance_eval &block
      end
    end

    # @api public
    #
    # @overload locate(service, uri)
    #   Configures URL where a service can be reached.
    #
    #   @param [Symbol] service Service identity key for service that is reachable under given URL.
    #   @param [String] uri URL where service is reachable. Will be passed to {URI.parse}.
    #   @return [undefined]
    #
    # @overload locate(service)
    #   Return configured base URL for given service identity key.
    #
    #   @param [Symbol] service Service identity key to lookup.
    #   @return [URI, NilClass] Configured base URL or nil.
    #
    def locate(service, uri = nil)
      service = service.to_s.underscore.to_sym
      if uri.nil?
        locations[service]
      else
        locations[service] = URI.parse uri
      end
    end

    # @api public
    #
    # Load configuration from given YAML file.
    #
    # @param [String] filename Path to YAML configuration file.
    # @return [undefined]
    #
    def load(filename)
      config = YAML.load File.read filename
      env    = ENV['RACK_ENV'] || ENV['RAILS_ENV'] || 'development'

      config = config[env] if config.key? env
      config.each do |key, value|
        case key
          when 'services' then load_services value
        end
      end
    end

    # @api private
    #
    # Load services from configuration YAML.
    #
    def load_services(services)
      services.each do |service, data|
        if (val = data).is_a?(String) || (val = data['locate'])
          locate service.to_sym, val
        end
      end
    end

    class << self
      # @api private
      #
      # Return current configuration object.
      #
      # @return [Configuration]
      #
      def current
        @configuration ||= new
      end

      # @api private
      #
      # Swap configuration object with given new one. Must be a {Configuration} object.
      #
      # @param [Configuration] configuration
      # @return [undefined]
      #
      def set(configuration)
        @configuration = configuration if configuration.is_a? Configuration
      end
    end
  end
end
