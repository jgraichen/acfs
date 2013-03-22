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

    # Try to load a resource by given id.
    #
    def find(id, &block)
      model = resource_class.new

      request = case id
                  when Hash
                    Acfs::Request.new url, params: id
                  else
                    Acfs::Request.new url(id.to_s)
                end

      client.queue(request) do |response|
        model.attributes = response.data
        block.call model unless block.nil?
      end

      model
    end

    # Trt to load all resources.
    #
    def all(params = {}, &block)
      collection = Collection.new

      client.queue(Acfs::Request.new(url, params: params)) do |response|
        response.data.each do |obj|
          collection << resource_class.new.tap { |m| m.attributes = obj }
        end
        block.call collection unless block.nil?
      end

      collection
    end

    def url(suffix = nil)
      "#{client.base_url}/#{name.to_s || options[:path]}".tap do |url|
        url << "/#{suffix.to_param}" if suffix
      end
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
