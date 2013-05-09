require 'active_support'
require 'active_support/core_ext/class'
require 'active_support/core_ext/hash'
require 'active_support/core_ext/module'

require 'acfs/version'
require 'acfs/errors'

module Acfs
  extend ActiveSupport::Autoload

  autoload :Collection
  autoload :Model
  autoload :Request
  autoload :Response
  autoload :Service
  autoload :Stub

  module Middleware
    extend ActiveSupport::Autoload

    autoload :Base
    autoload :Print
    autoload :Logger
    autoload :JsonDecoder
    autoload :MessagePackDecoder, 'acfs/middleware/msgpack_decoder'
    autoload :JsonEncoder
    autoload :MessagePackEncoder, 'acfs/middleware/msgpack_encoder'
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

    def adapter
      @adapter ||= Adapter::Typhoeus.new
    end
  end
end

