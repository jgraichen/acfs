# frozen_string_literal: true

class Acfs::Resource
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
      # @overload url(suffix)
      #   @deprecated
      #   Return URL for this class of resource. Given suffix
      #   will be appended.
      #
      #   @example
      #     User.url    # => "http://users.srv.org/users"
      #     User.url(5) # => "http://users.srv.org/users/5"
      #
      #   @param suffix [String] Suffix to append to URL.
      #   @return [String] Generated URL.
      #
      # @overload url(opts = {})
      #   Return URL for this class of resources. Given options
      #   will be used to replace URL path arguments and to
      #   determine the operation action.
      #
      #   @example
      #     User.url(id: 5, action: :read) # => "http://users.srv.org/users/5"
      #     User.url(action: :list) # => "http://users.srv.org/users"
      #
      #   @param opts [Hash] Options.
      #   @option opts [Symbol] :action Operation action,
      #     usually `:list`, `:create`, `:read`, `:update` or`:delete`.
      #   @return [String] Generated URL.
      #
      def url(suffix = nil, **opts)
        if suffix.is_a? Hash
          opts = suffix
          suffix = nil
        end

        opts[:action] = :list if suffix

        url  = location(**opts).build(**opts).str
        url += "/#{suffix}" if suffix.to_s.present?
        url
      end

      # Return a location object able to build the URL for this
      # resource and given action.
      #
      # @example
      #   class Identity < ::Acfs::Resource
      #     service MyService, path: 'users/:user_id/identities'
      #   end
      #
      #   location = Identity.location(action: :read)
      #   location.arguments
      #   => [:user_id, :id]
      #
      #   location.raw_url
      #   => 'http://service/users/:user_id/identities/:id'
      #
      #   location = Identity.location(action: :list)
      #   location.arguments
      #   => [:user_id]
      #
      #   location.build(user_id: 42)
      #   => 'http://service/users/42/identities'
      #
      # @param opts [Hash] Options.
      # @option opts [Symbol] :action Operation action,
      #   usually `:list`, `:create`, `:read`, `:update` or`:delete`.
      #
      # @return [Location] Location object.
      #
      def location(**opts)
        service.location(self, **opts)
      end

      # @api private
      def location_default_path(action, path)
        case action
          when :list, :create
            path
          when :read, :update, :delete
            "#{path}/:id"
        end
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
    def url(**opts)
      return nil if need_primary_key? && !primary_key?

      self.class.service
          .location(self.class, **opts, action: :read)
          .build(**attributes).str
    end

    # @api private
    # Return true if resource needs a primary key (id) for singular actions.
    def need_primary_key?
      true
    end

    # @api private
    # Return true if resource has a primary key (id) set.
    def primary_key?
      respond_to?(:id) && !id.nil?
    end
  end
end
