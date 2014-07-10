require 'active_support'
require 'active_support/core_ext/hash'
require 'active_support/core_ext/class'
require 'active_support/core_ext/string'
require 'active_support/core_ext/module'
require 'active_support/notifications'

module Acfs
  extend ActiveSupport::Autoload
  require 'acfs/version'
  require 'acfs/errors'
  require 'acfs/global'
  require 'acfs/util'

  require 'acfs/collection'
  require 'acfs/configuration'
  require 'acfs/location'
  require 'acfs/model'
  require 'acfs/operation'
  require 'acfs/request'
  require 'acfs/resource'
  require 'acfs/response'
  require 'acfs/runner'
  require 'acfs/service'
  require 'acfs/singleton_resource'

  extend Global

  autoload :Stub

  module Middleware
    extend ActiveSupport::Autoload
    require 'acfs/middleware/base'
    require 'acfs/middleware/serializer'

    autoload :Print
    autoload :Logger
    autoload :JSON
    autoload :JsonDecoder
    autoload :JsonEncoder
    autoload :MessagePack, 'acfs/middleware/msgpack'
    autoload :MessagePackDecoder, 'acfs/middleware/msgpack_decoder'
    autoload :MessagePackEncoder, 'acfs/middleware/msgpack_encoder'
  end

  module Adapter
    require 'acfs/adapter/base'
    require 'acfs/adapter/typhoeus'
  end
end

