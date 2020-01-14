# frozen_string_literal: true

module Acfs
  module Util
    # TODO: Merge wit features in v1.0
    module Callbacks
      def __callbacks__
        @__callbacks__ ||= []
      end

      def __invoke__
        __callbacks__.each {|c| c.call self }
      end
    end

    # TODO: Replace delegator with promise or future for the long run.
    class ResourceDelegator < SimpleDelegator
      delegate :class, :is_a?, :kind_of?, :nil?, to: :__getobj__
      include Callbacks
    end
  end
end
