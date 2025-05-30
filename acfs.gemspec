# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'acfs/version'

Gem::Specification.new do |spec|
  spec.name          = 'acfs'
  spec.version       = Acfs::VERSION
  spec.authors       = ['Jan Graichen']
  spec.email         = %w[jgraichen@altimos.de]
  spec.homepage      = 'https://github.com/jgraichen/acfs'
  spec.license       = 'MIT'
  spec.description   = 'API Client For Services'
  spec.summary       = <<~SUMMARY.strip
    An abstract API base client for service oriented application.
  SUMMARY

  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files = Dir['**/*'].grep(%r{
    ^((bin|lib|test|spec|features)/|
    .*\.gemspec|.*LICENSE.*|.*README.*|.*CHANGELOG.*)
  }xi)

  spec.executables   = spec.files.grep(%r{^bin/}) {|f| File.basename(f) }
  spec.require_paths = %w[lib]

  spec.required_ruby_version = '>= 3.1.0'

  spec.add_dependency 'actionpack', '>= 7.0'
  spec.add_dependency 'activemodel', '>= 7.0'
  spec.add_dependency 'activesupport', '>= 7.0'
  spec.add_dependency 'multi_json', '~> 1.0'
  spec.add_dependency 'opentelemetry-api', '~> 1.0'
  spec.add_dependency 'opentelemetry-common'
  spec.add_dependency 'rack'
  spec.add_dependency 'typhoeus', '~> 1.0'
end
