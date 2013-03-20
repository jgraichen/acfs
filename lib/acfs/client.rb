require 'active_support/core_ext/class'
require 'acfs/resources'

module Acfs
  class Client
    cattr_accessor :base_url

    include Acfs::Resources

    # Initializes a new API client object. Allows to override global
    # config options.
    #
    #   client = MyApiClient.new base_url: 'http://myservice.com'
    #   client.base_url # => "http://myservice.com"
    #
    def initialize(opts = {})
      @base_url = opts[:base_url] || self.class.base_url
    end

    # Return runtime base URL.
    #
    def base_url
      @base_url
    end

  end
end
