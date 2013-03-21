require 'multi_json'

module Acfs

  # A wrapper for collection of resources providing
  # methods to access singular or multiple resources.
  #
  class Resource
    attr_reader :name, :options, :client

    def initialize(client, name, options = {})
      @name    = name
      @client  = client
      @options = options
    end

    def find(id)
      model = resource_class.new
      url = "#{client.base_url}/#{name}/#{id}"

      request = Typhoeus::Request.new url, followlocation: true
      request.on_complete do |response|
        model.attributes = ::MultiJson.load response.body
      end

      Acfs.hydra.queue request

      model
    end

    def resource_class
      return options[:class] if options[:class].is_a? Class

      (options[:class] || name).to_s.singularize.camelcase.constantize
    end
  end
end
