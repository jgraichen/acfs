module Acfs

  # Allows to define and load API resources in a client class.
  #
  #   class MyClient < Acfs::Client
  #     resources :users
  #   end
  #
  #   MyClient.new.fetch do |client|
  #     @user = client.users.fetch(1) do |user|
  #       @comments = user.comments.all
  #     end
  #   end
  #
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
      def resources(name, opts = {})

      end
    end
  end
end
