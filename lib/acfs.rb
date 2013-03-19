require 'active_support'
require 'acfs/version'

module Acfs
  extend ActiveSupport::Autoload

  autoload :Client
  autoload :Base

  autoload :Model
  autoload :Attributes
  autoload :Initialization

end
