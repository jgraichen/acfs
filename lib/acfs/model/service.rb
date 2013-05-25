module Acfs::Model

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
      #   @return [ Service ] Service class instance.
      #
      # @overload service(klass, options = {})
      #   Link to service this model belongs to. Connection settings like base URL
      #   are fetched from service. Return assigned service if no arguments are given.
      #
      #   @example
      #     class AccountService < Acfs::Client
      #       self.base_url = 'http://acc.serv.org'
      #     end
      #
      #     class MyUser
      #       service AccountService
      #     end
      #     MyUser.find 5 # Will fetch `http://acc.serv.org/users/5`
      #
      #   @param [ Class ] klass Service class derived from {Acfs::Service}.
      #   @param [ Object ] options Option delegated to service class initializer.
      #
      def service(klass = nil, options = {})
        return @service unless klass
        @service = klass.new options
      end
    end
  end
end
