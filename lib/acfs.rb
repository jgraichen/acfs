require 'active_support'
require 'active_support/core_ext'
require 'acfs/version'

module Acfs
  extend ActiveSupport::Autoload

  autoload :Collection
  autoload :Model
  autoload :Request
  autoload :Response
  autoload :Service

  module Middleware
    extend ActiveSupport::Autoload

    autoload :Base
    autoload :Print
    autoload :JsonDecoder
  end

  module Adapter
    extend ActiveSupport::Autoload

    autoload :Typhoeus
  end

  class << self

    # Run all queued
    def run
      adapter.run
    end

    def queue(req, &block)
      request = middleware.call Request.new(req)
      request.on_complete &block if block_given?
      adapter.queue request
    end

    def adapter
      @adapter ||= Adapter::Typhoeus.new
    end

    def middleware
      @middleware ||= lambda { |request| request }
    end

    def use(klass, options = {})
      @middlewares ||= []

      return false if @middlewares.include? klass

      @middlewares << klass
      @middleware = klass.new(middleware, options)
    end
  end
end
