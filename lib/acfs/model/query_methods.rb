module Acfs::Model

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

      # Try to load a resource by given id.
      #
      # Example
      #   User.find(5) # Will query `http://base.url/users/5`
      #
      def find(id, options = {}, &block)
        model = self.new

        request = case id
                    when Hash
                      Acfs::Request.new url, params: id
                    else
                      Acfs::Request.new url(id.to_s)
                  end

        service.new(options).queue(request) do |response|
          model.attributes = response.data
          block.call model unless block.nil?
        end

        model
      end
    end
  end
end
