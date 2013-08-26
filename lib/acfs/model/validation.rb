module Acfs::Model

  #
  #
  module Validation

    def save!(*_)
      raise ::Acfs::InvalidResource.new resource: self, errors: errors.to_a unless valid? :save

      super
    end
  end
end
