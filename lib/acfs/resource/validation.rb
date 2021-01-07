# frozen_string_literal: true

class Acfs::Resource
  module Validation
    def remote_errors
      @remote_errors ||= ActiveModel::Errors.new self
    end

    def remote_errors=(errors)
      if errors.respond_to?(:each_pair)
        errors.each_pair do |field, errs|
          Array(errs).each do |err|
            self.errors.add field.to_sym, err
            remote_errors.add field.to_sym, err
          end
        end
      else
        Array(errors).each do |err|
          self.errors.add :base, err
          remote_errors.add :base, err
        end
      end
    end

    def save!(**kwargs)
      unless valid?(new? ? :create : :save)
        raise ::Acfs::InvalidResource.new resource: self, errors: errors.to_a
      end

      super
    end

    if ::ActiveModel.version >= Gem::Version.new('6.1')
      def valid?(*args)
        super

        remote_errors.each {|e| errors.add(e.attribute, e.message) }
        errors.empty?
      end
    else
      def valid?(*args)
        super

        remote_errors.each {|f, e| errors.add(f, e) }
        errors.empty?
      end
    end
  end
end
