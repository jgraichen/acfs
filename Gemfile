# frozen_string_literal: true

source 'https://rubygems.org'

git_source(:github) {|repo| "https://github.com/#{repo}.git" }

gemspec

# Development gems
#
gem 'appraisal'
gem 'json', '~> 2.1'
gem 'rake'
gem 'rspec', '~> 3.6'
gem 'rspec-collection_matchers'
gem 'rspec-its'
gem 'webmock', '~> 3.0'

gem 'rake-release', '~> 1.0'

# Doc
group :development do
  gem 'redcarpet', platform: :ruby
  gem 'yard', '~> 0.9.24'

  gem 'rubocop-config', github: 'jgraichen/rubocop-config', tag: 'v14'
end

group :test do
  gem 'msgpack', '~> 1.1'
  gem 'pry'
  gem 'pry-byebug'

  gem 'simplecov'
  gem 'simplecov-cobertura'
end
