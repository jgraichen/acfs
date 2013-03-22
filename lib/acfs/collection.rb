module Acfs

  class Collection < Delegator

    def initialize
      super([])
    end

    def __getobj__
      @models
    end

    def __setobj__(obj)
      @models = obj
    end
  end
end
