module Acfs::Model

  #
  #
  module Validation

    def valid?(*args)
      super
      remote_errors.each { |f, e| errors.add f, e }
      errors.empty?
    end

    def remote_errors
      @remote_errors ||= ActiveModel::Errors.new self
    end

    def remote_errors=(errors)
      (errors || []).each do |field, errors|
        self.errors.set field.to_sym, errors
        self.remote_errors.set field.to_sym, errors
      end
    end

    def save!(*_)
      raise ::Acfs::InvalidResource.new resource: self, errors: errors.to_a unless valid? (new? ? :create : :save)

      super
    end
  end
end
