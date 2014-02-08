require 'acfs/service/middleware'

module Acfs

  # User {Acfs::Service} to define your services. That includes
  # an identity used to identify the service in configuration files
  # and middlewares the service uses.
  #
  # Configure your service URLs in a YAML file loaded in an
  # initializer using the identity as a key:
  #
  #   production:
  #     services:
  #       user_service_key: "http://users.service.org/base/path"
  #
  # @example
  #   class UserService < Acfs::Service
  #     identity :user_service_key
  #
  #     use Acfs::Middleware::MessagePackDecoder
  #   end
  #
  class Service
    attr_accessor :options

    include Service::Middleware

    # @api private
    #
    def initialize(options = {})
      @options = options
    end

    # @api private
    # @return [Location]
    #
    def location(resource_class, opts = {})
      opts.reverse_merge! self.options

      url  = self.class.base_url.to_s
      url += resource_class.path_defaults[opts[:action] || :list] || '/:path'

      path = opts[:path]
      path ||= (resource_class.name || 'class').pluralize.underscore

      Location.new Location.new(url).build(raise: false, path: path).str
    end

    class << self

      # @api public
      #
      # @overload identity()
      #   Return configured identity key or derive key from class name.
      #
      #   @return [Symbol] Service identity key.
      #
      # @overload identity(identity)
      #   Set identity key.
      #
      #   @param [#to_s] identity New identity key.
      #   @return [Symbol] New set identity key.
      #
      def identity(identity = nil)
        @identity = identity.to_s.to_sym unless identity.nil?
        @identity ||= name.to_sym
      end

      # @api private
      # @return [String]
      #
      def base_url
        unless (base = Acfs::Configuration.current.locate identity)
          raise ArgumentError, "#{identity} not configured. Add `locate '#{identity.to_s.underscore}', 'http://service.url/'` to your configuration."
        end

        base.to_s
      end
    end
  end
end
