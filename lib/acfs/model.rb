require 'active_model'

# @api public
#
module Acfs::Model
  require 'acfs/model/attributes'
  require 'acfs/model/dirty'
  require 'acfs/model/loadable'
  require 'acfs/model/locatable'
  require 'acfs/model/operational'
  require 'acfs/model/persistence'
  require 'acfs/model/query_methods'
  require 'acfs/model/relations'
  require 'acfs/model/service'
  require 'acfs/model/validation'

  extend ActiveSupport::Concern

  included do
    if ActiveModel::VERSION::MAJOR >= 4
      include ActiveModel::Model
    else
      extend  ActiveModel::Naming
      extend  ActiveModel::Translation
      include ActiveModel::Conversion
      include ActiveModel::Validations

      require 'acfs/model/initialization'
      include Initialization
    end

    include Attributes
    include Loadable
    include Persistence
    include Locatable
    include Operational
    include QueryMethods
    include Relations
    include Service
    include Dirty
    include Validation
  end
end
