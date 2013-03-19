module Acfs
  module VERSION
    MAJOR = 0
    MINOR = 1
    PATCH = 0
    STAGE = 'dev'

    def self.to_s
      [MAJOR, MINOR, PATCH, STAGE].reject(&:nil?).join('.')
    end
  end
end
