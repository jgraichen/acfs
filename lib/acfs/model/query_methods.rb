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
      #   @param [ Hash ] opts Additional options.
      #   @option opts [ Hash ] :params Additional parameters added to request. `:id` will be overridden
      #     with given ID.
      #
      #   @yield [ resource ] Callback block to be executed after resource was fetched successfully.
      #   @yieldparam resource [ self ] Fetched resources.
      #
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
      #   @param [ Hash ] opts Additional options.
      #   @option opts [ Hash ] :params Additional parameters added to request. `:id` will be overridden
      #     with individual resource ID.
      #
      #   @yield [ collection ] Callback block to be executed after collection was fetched successfully.
      #   @yieldparam resource [ Collection ] Collection with fetched resources.
      #
      #   @return [ Collection ] Collection of requested resources if multiple IDs were given.
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
            collection << create_resource(obj)
          end
          collection.loaded!
          block.call collection unless block.nil?
        end

        collection
      end
      alias :where :all

      # @api public
      #
      # Try to load first resource. Return nil if no object can be loaded.
      #
      # @param [ Hash  ] params Request parameters that will be send to remote service.
      #
      # @yield [ resource ] Callback block to be executed after resource was fetched (even if nil).
      # @yieldparam resource [ self ] Fetched resource, nil if empty list is returned
      #
      # @return [ self ] Resource object, nil if empty list is returned
      #
      def find_by(params, &block)
        model = Acfs::Util::ResourceDelegator.new self.new
        model.__callbacks__ << block unless block.nil?

        operation :list, params: params do |data|
          if data.empty?
            model.__setobj__ nil
          else
            model.__setobj__ create_resource data.first, origin: model.__getobj__
          end
          model.__invoke__
        end

        model
      end

      # @api public
      #
      # Try to load first resource. Raise Acfs::ResourceNotFound exception if no object can be loaded.
      #
      # @param [ Hash  ] params Request parameters that will be send to remote service.
      #
      # @yield [ resource ] Callback block to be executed after resource was fetched successfully.
      # @yieldparam resource [ self ] Fetched resource, nil if empty list is returned
      #
      # @return [ self ] Resource object, nil if empty list is returned
      #
      def find_by!(params, &block)
        find_by params do |m|
          raise Acfs::ResourceNotFound.new message: "Recieved erronious response: no `#{self.name}` with params #{params.to_s} found" if m.nil?
          block.call m unless block.nil?
        end
      end

      private
      def find_single(id, opts, &block)
        model = Acfs::Util::ResourceDelegator.new self.new

        opts[:params] ||= {}
        opts[:params].merge!({ id: id })

        model.__callbacks__ << block unless block.nil?

        operation :read, opts do |data|
          model.__setobj__ create_resource data, origin: model.__getobj__
          model.__invoke__
        end

        model
      end

      def find_multiple(ids, opts, &block)
        ::Acfs::Collection.new.tap do |collection|
          collection.__callbacks__ << block unless block.nil?

          counter = 0
          ids.each do |id|
            find_single id, opts do |resource|
              collection << resource
              if (counter += 1) == ids.size
                collection.loaded!
                collection.__invoke__
              end
            end
          end
        end
      end

      def create_resource(data, opts = {})
        type = data.delete 'type'
        klass = resource_class_lookup(type)
        (opts[:origin].is_a?(klass) ? opts[:origin] : klass.new).tap do |m|
          m.attributes = data
          m.loaded!
        end
      end

      def resource_class_lookup(type)
        return self if type.nil?
        klass = type.camelize.constantize
        raise Acfs::ResourceTypeError.new type_name: type, base_class: self unless klass <= self
        klass
      rescue NameError, NoMethodError
        raise Acfs::ResourceTypeError.new type_name: type, base_class: self
      end

    end
  end
end
