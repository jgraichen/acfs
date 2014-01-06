require 'rspec'
require 'rspec/its'
require 'rspec/collection_matchers'
require 'webmock/rspec'

if ENV['CI'] || (defined?(:RUBY_ENGINE) && RUBY_ENGINE != 'rbx')
  require 'coveralls'
  Coveralls.wear! do
    add_filter 'spec'
  end
end

require 'bundler'
Bundler.require

require 'acfs'

Dir[File.expand_path('spec/support/**/*.rb')].each {|f| require f}

RSpec.configure do |config|
  # ## Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = 'random'

  # Raise error when using old :should expectation syntax.
  config.raise_errors_for_deprecations!

  config.before :each do
    Acfs.runner.clear
    Acfs::Stub.clear
  end
end
