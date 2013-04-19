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
      #   User.find(5)       # Will query `http://base.url/users/5`
      #   User.find(1, 2, 5) # Will return collection and will query
      #                      # `http://base.url/users/1`, `http://base.url/users/2`
      #                      # and `http://base.url/users/5` parallel
      #
      def find(*attrs, &block)
        opts  = attrs.extract_options!

        attrs.size > 1 ? find_multiple(attrs, opts, &block) : find_single(attrs[0], opts, &block)
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

      private
      def find_single(id, opts, &block)
        model = self.new

        request = Acfs::Request.new url(id.to_s)
        service.queue(request) do |response|
          model.attributes = response.data
          model.loaded!
          block.call model unless block.nil?
        end

        model
      end

      def find_multiple(ids, opts, &block)
        ::Acfs::Collection.new.tap do |collection|
          counter = 0
          ids.each do |id|
            find_single id, opts do |resource|
              collection << resource
              if (counter += 1) == ids.size
                collection.loaded!
                block.call collection unless block.nil?
              end
            end
          end
        end
      end
    end
  end
end
