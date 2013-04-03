module Acfs

  # Service object.
  #
  class Service
    attr_accessor :options
    class_attribute :base_url

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

    def queue(request, &block)
      Acfs.queue request, &block
    end
  end
end
