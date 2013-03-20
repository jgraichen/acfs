require 'active_support/core_ext/class'
require 'acfs/resources'

module Acfs
  class Client
    attr_reader :options
    cattr_accessor :base_url

    include Acfs::Resources

    # Initializes a new API client object. Allows to override global
    # config options.
    #
    #   client = MyApiClient.new base_url: 'http://myservice.com'
    #   client.base_url # => "http://myservice.com"
    #
    def initialize(opts = {})
      @options = opts
    end

    # Return runtime base URL.
    #
    def base_url
      options[:base_url] || self.class.base_url
    end

  end
end
