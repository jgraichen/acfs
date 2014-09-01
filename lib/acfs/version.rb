module Acfs
  module VERSION
    MAJOR = 0
    MINOR = 41
    PATCH = 1
    STAGE = :beta1

    STRING = [MAJOR, MINOR, PATCH, STAGE].reject(&:nil?).join('.')

    def self.to_s; STRING end
  end
end
