require 'active_support'
require 'acfs/version'

module Acfs
  extend ActiveSupport::Autoload

  autoload :Attributes
  autoload :Client
  autoload :Collection
  autoload :Initialization
  autoload :Model
  autoload :Relations
  autoload :Resource
  autoload :Resources

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
