require 'multi_json'
require 'acfs/collection'

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

    # Try to load a resource by given id.
    #
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

    # Trt to load all resources.
    #
    def all
      collection = Collection.new
      url = "#{client.base_url}/#{name}"

      request = Typhoeus::Request.new url, followlocation: true
      request.on_complete do |response|
        json = ::MultiJson.load response.body
        json.each do |obj|
          collection << resource_class.new.tap { |m| m.attributes = obj }
        end
      end

      Acfs.hydra.queue request

      collection
    end

    # Return resource class. The resource class will be extracted
    # from the resource name or can be specified by the `:class` option.
    #
    #   class User
    #     resource :friends # Will have class Friend
    #     resource :comment_votes, class: 'Vote' # Will have class Vote
    #   end
    #
    def resource_class
      return options[:class] if options[:class].is_a? Class

      (options[:class] || name).to_s.singularize.camelcase.constantize
    end
  end
end
