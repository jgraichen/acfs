# frozen_string_literal: true

module Acfs
  module VERSION
    MAJOR = 1
    MINOR = 3
    PATCH = 2
    STAGE = nil

    STRING = [MAJOR, MINOR, PATCH, STAGE].reject(&:nil?).join('.')

    def self.to_s
      STRING
    end
  end
end
