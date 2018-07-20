require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)
task default: :spec

# rubocop:disable HandleExceptions
begin
  require 'rake/release/task'

  Rake::Release::Task.new do |spec|
    spec.sign_tag = true
  end
rescue LoadError
end

# rubocop:disable HandleExceptions
begin
  require 'yard'
  require 'yard/rake/yardoc_task'

  YARD::Rake::YardocTask.new do |t|
    t.files = %w(lib/**/*.rb)
    t.options = %w(--output-dir doc/)
  end
rescue LoadError
end
