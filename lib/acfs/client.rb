require 'active_support/core_ext/class'

module Acfs
  class Client
    attr_reader :base_url
    class_attribute :base_url

    include Acfs::Resources

    # Initializes a new API client object. Allows to override global
    # config options.
    #
    #   client = MyApiClient.new base_url: 'http://myservice.com'
    #   client.base_url # => "http://myservice.com"
    #
    def initialize(opts = {})
      @base_url = opts.delete(:base_url) || self.class.base_url
    end
  end
end
