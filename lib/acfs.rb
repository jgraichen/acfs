require 'active_support'
require 'active_support/core_ext/hash'
require 'active_support/core_ext/class'
require 'active_support/core_ext/string'
require 'active_support/core_ext/module'

module Acfs
  extend ActiveSupport::Autoload
  require 'acfs/version'
  require 'acfs/errors'
  require 'acfs/global'

  require 'acfs/collection'
  require 'acfs/configuration'
  require 'acfs/model'
  require 'acfs/operation'
  require 'acfs/request'
  require 'acfs/resource'
  require 'acfs/response'
  require 'acfs/runner'
  require 'acfs/service'

  extend Global

  autoload :Stub

  module Middleware
    extend ActiveSupport::Autoload
    require 'acfs/middleware/base'

    autoload :Print
    autoload :Logger
    autoload :JsonDecoder
    autoload :MessagePackDecoder, 'acfs/middleware/msgpack_decoder'
    autoload :JsonEncoder
    autoload :MessagePackEncoder, 'acfs/middleware/msgpack_encoder'
  end

  module Adapter
    require 'acfs/adapter/base'
    require 'acfs/adapter/typhoeus'
  end
end

