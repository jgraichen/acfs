require 'active_model'

require 'acfs/model/attributes'
require 'acfs/model/locatable'
require 'acfs/model/query_methods'
require 'acfs/model/relations'
require 'acfs/model/service'

module Acfs
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

        require 'model/initialization'
        include Model::Initialization
      end

      include Model::Attributes
      include Model::QueryMethods
      include Model::Relations
      include Model::Service
    end
  end
end
