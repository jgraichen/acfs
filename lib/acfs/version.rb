module Acfs
  module VERSION
    MAJOR = 0
    MINOR = 49
    PATCH = 0
    STAGE = nil

    STRING = [MAJOR, MINOR, PATCH, STAGE].reject(&:nil?).join('.')

    def self.to_s
      STRING
    end
  end
end
