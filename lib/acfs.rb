require 'active_support'
require 'acfs/version'

require 'acfs/client'
require 'acfs/model'

module Acfs


  class << self

    # Run all queued
    def run
      hydra.run
    end

    def hydra
      @hydra ||= Typhoeus::Hydra.new
    end
  end
end
