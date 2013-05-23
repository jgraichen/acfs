source 'https://rubygems.org'

# Development gems
#
gem 'webmock', '~> 1.7'
gem 'rake'
gem 'rspec'
gem 'guard-rspec'
gem 'coveralls'

# Doc
group :development do
  gem 'yard', '~> 0.8.6'
  gem 'listen'
  gem 'guard-yard'
  gem 'guard-rspec'
  gem 'redcarpet', platform: :ruby
end

# Platform specific development dependencies
#
gem 'msgpack', platform: :ruby
gem 'msgpack-jruby', require: 'msgpack', platform: :jruby

# Specify your gem's dependencies in acfs.gemspec
gemroot = File.dirname File.absolute_path __FILE__
gemspec path: gemroot
