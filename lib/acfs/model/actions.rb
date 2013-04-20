module Acfs
  module Model

    # Actions to save and update model resources.
    # TODO: Atm only stubs
    module Actions
      extend ActiveSupport::Concern

      def save
        save!
      rescue
        false
      end

      def save!

      end
    end
  end
end
