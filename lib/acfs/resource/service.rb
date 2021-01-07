# frozen_string_literal: true

class Acfs::Resource
  # Included by Acfs::Model. Allows to configure the service
  # a resource belongs to.
  #
  module Service
    extend ActiveSupport::Concern

    module ClassMethods
      # @api public
      #
      # @overload service()
      #   Return service instance.
      #
      #   @return [Service] Service class instance.
      #
      # @overload service(klass, options = {})
      #   Link to service this model belongs to. Connection
      #   settings like base URL are fetched from service.
      #   Return assigned service if no arguments are given.
      #
      #   @example
      #     class AccountService < Acfs::Client
      #       self.base_url = 'http://acc.serv.org'
      #     end
      #
      #     class MyUser < Acfs::Resource
      #       service AccountService
      #     end
      #     MyUser.find 5 # Will fetch `http://acc.serv.org/users/5`
      #
      #   @param klass [Class] Service class derived from {Acfs::Service}.
      #   @param options [Object] Option delegated to
      #     service class initializer.
      #
      def service(klass = nil, **options)
        return (@service = klass.new(**options)) if klass

        @service || superclass.service
      end
    end
  end
end
