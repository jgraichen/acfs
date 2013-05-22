module Acfs::Model

  # Provide methods for generation URLs for resources.
  #
  # @example
  #   class User
  #     service AccountService # With base URL `http://acc.svr`
  #   end
  #   User.url    # => "http://acc.svr/users"
  #   User.url(5) # => "http://acc.svr/users/5"
  #
  module Locatable
    extend ActiveSupport::Concern

    module ClassMethods

      # Return URL for this class of resource. Given suffix will be appended.
      #
      # @example
      #   User.url    # => "http://users.srv.org/users"
      #   User.url(5) # => "http://users.srv.org/users/5"
      #
      # @param [ String ] suffix Suffix to append to URL.
      # @return [ String ] Generated URL.
      # @see Acfs::Service#url_for Delegates to Service#url_for with `suffix` option.
      #
      def url(suffix = nil)
        service.url_for(self, suffix: suffix)
      end
    end

    # Return URL for this resource. Resource if will be appended
    # as suffix if present.
    #
    # @example
    #   user.new.url # => "http://users.srv.org/users"
    #
    #   user = User.find 5
    #   Acfs.run
    #   user.url # => "http://users.srv.org/users/5"
    #
    # @return [ String ] Generated URL.
    # @see ClassMethods#url
    #
    def url
      return nil if id.nil?
      self.class.service.url_for self, suffix: read_attribute(:id)
    end
  end
end
