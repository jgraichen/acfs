require 'active_model'
require 'acfs/attributes'
require 'acfs/initialization'

module Acfs
  module Model
    def self.included(base)
      base.class_eval do
        if ActiveModel::VERSION::MAJOR >= 4
          include ActiveModel::Model
        else
          extend  ActiveModel::Naming
          extend  ActiveModel::Translation
          include ActiveModel::Conversion
          include ActiveModel::Validations

          include Acfs::Initialization
        end

        include Acfs::Attributes
      end
    end
  end
end
