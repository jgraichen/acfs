source 'https://rubygems.org'

# Development gems
#
gem 'webmock', '~> 1.7'
gem 'rake'
gem 'rspec', '~> 2.14'
gem 'coveralls'
gem 'json', '~> 1.8.1'

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
platform :rbx do
  gem 'rubysl', '~> 2.0'
  gem 'rubinius-coverage'
end
gem 'msgpack', '< 0.5.8', platform: :ruby
gem 'msgpack-jruby', require: 'msgpack', platform: :jruby

# Specify your gem's dependencies in acfs.gemspec
gemroot = File.dirname File.absolute_path __FILE__
gemspec path: gemroot
