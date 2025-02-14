# frozen_string_literal: true

require 'active_support'
require 'active_support/core_ext/hash'
require 'active_support/core_ext/class'
require 'active_support/core_ext/string'
require 'active_support/core_ext/module'
require 'active_support/notifications'

require 'opentelemetry'
require 'opentelemetry/common'

module Acfs
  extend ActiveSupport::Autoload
  require 'acfs/version'
  require 'acfs/errors'
  require 'acfs/global'
  require 'acfs/util'
  require 'acfs/telemetry'

  require 'acfs/collection'
  require 'acfs/configuration'
  require 'acfs/location'
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
    autoload :JsonDecoder, 'acfs/middleware/json'
    autoload :JsonEncoder, 'acfs/middleware/json'
    autoload :MessagePack, 'acfs/middleware/msgpack'
    autoload :MessagePackDecoder, 'acfs/middleware/msgpack'
    autoload :MessagePackEncoder, 'acfs/middleware/msgpack'
  end

  module Adapter
    require 'acfs/adapter/base'
    require 'acfs/adapter/typhoeus'
  end
end
