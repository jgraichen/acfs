module Acfs
  module Model

    # Methods providing the query interface for finding resouces.
    #
    # Example
    #   class MyUser
    #     include Acfs::Model
    #   end
    #
    #   MyUser.find(5)               # Find single resource
    #   MyUser.all                   # Full or partial collection of
    #                                # resources
    #   Comment.where(user: user.id) # Collection with additional parameter
    #                                # to filter resources
    #
    module QueryMethods
      extend ActiveSupport::Concern

      module ClassMethods

      end
    end
  end
end
