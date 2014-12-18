require 'active_model'

# @api public
#
class Acfs::Resource
  require 'acfs/resource/initialization'
  require 'acfs/resource/attributes'
  require 'acfs/resource/dirty'
  require 'acfs/resource/loadable'
  require 'acfs/resource/locatable'
  require 'acfs/resource/operational'
  require 'acfs/resource/persistence'
  require 'acfs/resource/query_methods'
  require 'acfs/resource/service'
  require 'acfs/resource/validation'

  if ActiveModel::VERSION::MAJOR >= 4
    include ActiveModel::Model
  else
    extend ActiveModel::Naming
    extend ActiveModel::Translation
    include ActiveModel::Conversion
    include ActiveModel::Validations
  end

  include Initialization

  include Attributes
  include Loadable
  include Persistence
  include Locatable
  include Operational
  include QueryMethods
  include Service
  include Dirty
  include Validation
end
