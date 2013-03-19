require 'active_support/core_ext/class/attribute_accessors'

module Acfs
  class Client
    attr_reader :base_url
    cattr_accessor :base_url

    # Initializes a new API client object. Allows to override global
    # config options.
    #
    #   client = MyApiClient.new base_url: 'http://myservice.com'
    #   client.base_url # => "http://myservice.com"
    #
    def initialize(opts = {})
      @base_url = opts[:base_url] || self.class.base_url
    end

    def load(&block)

    end
  end
end
