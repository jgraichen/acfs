source 'https://rubygems.org'

# Specify your gem's dependencies in acfs.gemspec
gemroot = File.dirname File.absolute_path __FILE__
gemspec path: gemroot

# Development gems
#
gem 'webmock', '~> 1.7'
gem 'rake'
gem 'rspec'
gem 'guard-rspec'
gem 'coveralls'

# Doc
gem 'yard', '~> 0.8.6'
gem 'redcarpet', platform: :ruby

# Platform specific development dependencies
#
gem 'msgpack', platform: :ruby
gem 'msgpack-jruby', require: 'msgpack', platform: :jruby
