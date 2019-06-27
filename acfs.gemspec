# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'acfs/version'

Gem::Specification.new do |spec|
  spec.name          = 'acfs'
  spec.version       = Acfs::VERSION
  spec.authors       = ['Jan Graichen']
  spec.email         = %w(jg@altimos.de)
  spec.description   = 'API Client For Services'
  spec.summary       = 'An abstract API base client for service oriented application.'
  spec.homepage      = 'https://github.com/jgraichen/acfs'
  spec.license       = 'MIT'

  spec.files         = Dir['**/*'].grep(%r{^((bin|lib|test|spec|features)/|.*\.gemspec|.*LICENSE.*|.*README.*|.*CHANGELOG.*)})
  spec.executables   = spec.files.grep(%r{^bin/}) {|f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = %w(lib)

  spec.add_runtime_dependency 'activesupport', '>= 4.2'
  spec.add_runtime_dependency 'activemodel', '>= 4.2'
  spec.add_runtime_dependency 'actionpack', '>= 4.2'
  spec.add_runtime_dependency 'multi_json'

  # Bundle update w/o version resolves to 0.3.3 ...
  spec.add_runtime_dependency 'typhoeus', '~> 1.0'

  spec.add_runtime_dependency 'rack'

  spec.add_development_dependency 'bundler'

  if ENV['TRAVIS_BUILD_NUMBER'] && !ENV['TRAVIS_TAG']
    # Append travis build number for auto-releases
    spec.version = "#{spec.version}.1.b#{ENV['TRAVIS_BUILD_NUMBER']}"
  end
end
