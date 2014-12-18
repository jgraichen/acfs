class Acfs::Resource
  #
  module Validation
    def valid?(*args)
      super
      remote_errors.each {|f, e| errors.add f, e }
      errors.empty?
    end

    def remote_errors
      @remote_errors ||= ActiveModel::Errors.new self
    end

    def remote_errors=(errors)
      (errors || []).each do |field, errs|
        self.errors.set field.to_sym, errs
        remote_errors.set field.to_sym, errs
      end
    end

    def save!(*_)
      unless valid?(new? ? :create : :save)
        raise ::Acfs::InvalidResource.new resource: self, errors: errors.to_a
      end
      super
    end
  end
end
