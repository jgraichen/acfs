require 'acfs/service/middleware'

module Acfs

  # Service object.
  #
  class Service
    attr_accessor :options

    include Service::Middleware

    def initialize(options = {})
      @options = options
    end

    def options
      @options
    end

    def url_for(resource_class, options = {})
      options.reverse_merge! self.options

      url  = self.class.base_url.to_s
      url += "/#{(options[:path] || resource_class.name.pluralize.underscore).to_s}"
      url += "/#{options[:suffix].to_s}" if options[:suffix]
      url
    end

    class << self

      def identity(identity = nil)
        @identity = identity.to_s.to_sym unless identity.nil?
        @identity ||= name.to_sym
      end

      def base_url
        unless (base = Acfs::Configuration.current.locate identity)
          raise ArgumentError, "#{identity} not configured. Add `locate '#{identity.to_s.underscore}', 'http://service.url/'` to your configuration."
        end

        base.to_s
      end
    end
  end
end
