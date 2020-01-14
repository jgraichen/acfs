# frozen_string_literal: true

class ActiveSupport::HashWithIndifferentAccess
  def ==(other)
    if other.respond_to? :with_indifferent_access
      super other.with_indifferent_access
    else
      super
    end
  end
end
