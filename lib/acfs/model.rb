require 'active_model'

require 'acfs/model/attributes'
require 'acfs/model/dirty'
require 'acfs/model/loadable'
require 'acfs/model/locatable'
require 'acfs/model/persistence'
require 'acfs/model/operational'
require 'acfs/model/query_methods'
require 'acfs/model/relations'
require 'acfs/model/service'

module Acfs

  # @api public
  #
  module Model
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
        include Model::Initialization
      end

      include Model::Attributes
      include Model::Loadable
      include Model::Persistence
      include Model::Locatable
      include Model::Operational
      include Model::QueryMethods
      include Model::Relations
      include Model::Service
      include Model::Dirty
    end
  end
end
