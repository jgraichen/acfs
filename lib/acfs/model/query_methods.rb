module Acfs::Model

  # Methods providing the query interface for finding resouces.
  #
  # @example
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

      # @api public
      #
      # @overload find(id, opts = {})
      #   Find a single resource by given ID.
      #
      #   @example
      #     user = User.find(5) # Will query `http://base.url/users/5`
      #
      #   @param [ Fixnum  ] id Resource IDs to fetch from remote service.
      #   @return [ self ] Resource object if only one ID was given.
      #
      # @overload find(*ids, opts = {})
      #   Load collection of specified resources by given IDs.
      #
      #   @example
      #     User.find(1, 2, 5) # Will return collection and will request
      #                        # `http://base.url/users/1`, `http://base.url/users/2`
      #                        # and `http://base.url/users/5` parallel
      #
      #   @param [ Fixnum, ... ] ids One or more resource IDs to fetch from remote service.
      #   @return [ Collection ] Collection of requested resources if multiple IDs were given.
      #
      # @option opts [ Hash ] :params Additional parameters added to request.
      #
      # @yield [ resource ] Callback block to be executed after resource or collection was fetched successfully.
      # @yieldparam resource [ self ] Fetched resource object.
      #
      def find(*attrs, &block)
        opts  = attrs.extract_options!

        attrs.size > 1 ? find_multiple(attrs, opts, &block) : find_single(attrs[0], opts, &block)
      end

      # @api public
      #
      # Try to load all resources.
      #
      # @param [ Hash  ] params Request parameters that will be send to remote service.
      #
      # @yield [ collection ] Callback block to be executed when resource collection was loaded successfully.
      # @yieldparam collection [ Collection ] Collection of fetched resources.
      #
      # @return [ Collection ] Collection of requested resources.
      #
      def all(params = {}, &block)
        collection = ::Acfs::Collection.new

        operation :list, params: params do |data|
          data.each do |obj|
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

        opts[:params] ||= {}
        opts[:params].merge!({ id: id })

        operation :read, opts do |data|
          model.attributes = data
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
