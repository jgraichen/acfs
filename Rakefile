# frozen_string_literal: true

require 'rake/release/task'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)
task default: :spec

Rake::Release::Task.new do |spec|
  spec.sign_tag = true
end

begin
  require 'yard'
  require 'yard/rake/yardoc_task'

  YARD::Rake::YardocTask.new do |t|
    t.files = %w[lib/**/*.rb]
    t.options = %w[--output-dir doc/]
  end
rescue LoadError # rubocop:disable Lint/SuppressedException
end
