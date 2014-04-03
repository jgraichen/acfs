module Acfs
  module VERSION
    MAJOR = 1
    MINOR = 0
    PATCH = 0
    STAGE = 'dev'

    STRING = [MAJOR, MINOR, PATCH, STAGE].reject(&:nil?).join('.')

    def self.to_s; STRING end
  end
end
