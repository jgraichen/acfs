require 'active_model'

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

        include Initialization
      end

      include Attributes
      include Relations
    end
  end
end
