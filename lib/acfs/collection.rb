# frozen_string_literal: true

require 'delegate'

require 'acfs/resource/loadable'
require 'acfs/collections/paginatable'

module Acfs
  class Collection < ::Delegator
    include Resource::Loadable
    include Acfs::Util::Callbacks
    include Collections::Paginatable

    def initialize(resource_class)
      super([])

      @resource_class = resource_class
    end

    def __getobj__
      @models
    end

    def __setobj__(obj)
      @models = obj
    end
  end
end
