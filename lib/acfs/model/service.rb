module Acfs
  module Model

    # Included by Acfs::Model. Allows a model to belong to a service.
    #
    module Service
      extend ActiveSupport::Concern

      module ClassMethods

        # Link to service this model belongs to. Connection settings like base URL
        # are fetched from service. Return assigned service if no arguments are given.
        #
        # Example
        #   class AccountService < Acfs::Client
        #     self.base_url = 'http://acc.serv.org'
        #   end
        #
        #   class MyUser
        #     service AccountService
        #   end
        #   MyUser.find 5 # Will fetch `http://acc.serv.org/users/5`
        #
        def service(klass = nil)
          return @service unless klass
          @service = klass
        end
      end
    end
  end
end
