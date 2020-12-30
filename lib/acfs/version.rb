# frozen_string_literal: true

module Acfs
  module VERSION
    MAJOR = 1
    MINOR = 5
    PATCH = 1
    STAGE = nil

    STRING = [MAJOR, MINOR, PATCH, STAGE].reject(&:nil?).join('.')

    def self.to_s
      STRING
    end
  end
end
