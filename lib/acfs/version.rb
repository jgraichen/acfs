# frozen_string_literal: true

module Acfs
  module VERSION
    MAJOR = 2
    MINOR = 2
    PATCH = 1
    STAGE = nil

    STRING = [MAJOR, MINOR, PATCH, STAGE].compact.join('.')

    def self.to_s
      STRING
    end
  end
end
