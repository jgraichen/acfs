require 'acfs/service/middleware'
require 'acfs/service/queue'

module Acfs

  # Service object.
  #
  class Service
    attr_accessor :options
    class_attribute :base_url

    include Service::Queue
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
  end
end
