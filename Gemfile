source 'https://rubygems.org'

# Development gems
#
gem 'webmock', '~> 3.0'
gem 'rake'
gem 'rspec', '~> 3.6'
gem 'rspec-its'
gem 'rspec-collection_matchers'
gem 'coveralls'
gem 'json', '~> 2.1'

# Doc
group :development do
  gem 'yard'
  gem 'listen'
  gem 'guard-yard'
  gem 'guard-rspec'
  gem 'redcarpet', platform: :ruby
end

group :test do
  gem 'pry'
  gem 'pry-byebug'

  platform :rbx do
    gem 'rubysl', '~> 2.0'
    gem 'rubinius-coverage'
  end

  gem 'msgpack', '~> 1.1'
end

# Specify your gem's dependencies in acfs.gemspec
gemroot = File.dirname File.absolute_path __FILE__
gemspec path: gemroot
