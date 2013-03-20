require 'acfs/collection'

module Acfs

  # Allows to define and load API resources in a client class.
  #
  #   class MyClient < Acfs::Client
  #     resources :users
  #   end
  #
  #   client = MyClient.new
  #   @user = client.users.fetch(1) do |user|
  #     @comments = user.comments.all
  #   end
  #
  # Returned objects are proxies that will contain no data until
  # request are fired and responses processed:
  #
  #    client.run
  #
  # Resource calls can also be automatically processed by wrapping
  # all in `Acfs::Client.run`:
  #
  #    client.run do |cl|
  #      @user = cl.users.fetch(1)
  #    end
  #    @user.name # => "Anon"
  #
  module Resources
    extend ActiveSupport::Concern

    module ClassMethods

      # Defines an API resource.
      #
      #   class MyClient
      #     resources :users
      #   end
      #
      # Will create a getter returning a resource collection
      # for accessing finders and loading sets of resources.
      #
      def resources(name, opts = {})
        collection = Collection.new name, opts

        define_method name.to_sym do
          collection
        end
      end
    end
  end
end
