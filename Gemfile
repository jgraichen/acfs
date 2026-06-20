# frozen_string_literal: true

source 'https://rubygems.org'

gemspec

# Development gems
#
gem 'appraisal'
gem 'rake'
gem 'rspec', '~> 3.6'
gem 'webmock', '~> 3.0'

gem 'rake-release', '~> 1.0'

# Doc
group :development do
  gem 'rubocop-config', github: 'jgraichen/rubocop-config', tag: 'v15'
end

group :test do
  gem 'msgpack', '~> 1.1'

  gem 'simplecov', require: false
  gem 'simplecov-cobertura', require: false
end
