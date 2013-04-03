module Acfs::Model

  # Provide methods for generation URLs for resources.
  #
  # Example
  #   class User
  #     service AccountService # With base URL `http://acc.svr`
  #   end
  #   User.url             #=> "http://acc.svr/users"
  #   User.url(5)          #=> "http://acc.svr/users/5"
  #
  module Locatable
    extend ActiveSupport::Concern

    module ClassMethods

      # Return URL for this resource.
      #
      def url(suffix = nil)
        service.url_for(self, suffix: suffix)
      end
    end
  end
end
