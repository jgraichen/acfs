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

        service.queue(request) do |response|
          model.attributes = response.data
          model.loaded!
          block.call model unless block.nil?
        end

        model
      end

      # Try to load all resources.
      #
      def all(params = {}, &block)
        collection = ::Acfs::Collection.new

        service.queue(Acfs::Request.new(url, params: params)) do |response|
          response.data.each do |obj|
            collection << self.new.tap do |m|
              m.attributes = obj
              m.loaded!
            end
          end
          collection.loaded!
          block.call collection unless block.nil?
        end

        collection
      end
      alias :where :all
    end
  end
end
