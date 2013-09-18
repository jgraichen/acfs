module Acfs
  module VERSION
    MAJOR = 0
    MINOR = 21
    PATCH = 0
    STAGE = 'rc1'

    STRING = [MAJOR, MINOR, PATCH, STAGE].reject(&:nil?).join('.')

    def self.to_s; STRING end
  end
end
