# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'acfs/version'

Gem::Specification.new do |spec|
  spec.name          = 'acfs'
  spec.version       = Acfs::VERSION
  spec.authors       = ['Jan Graichen']
  spec.email         = %w(jg@altimos.de)
  spec.description   = %q{API Client For Services}
  spec.summary       = %q{An abstract API base client for service oriented application.}
  spec.homepage      = 'https://github.com/jgraichen/acfs'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = %w(lib)

  spec.add_runtime_dependency 'activesupport', '>= 3.1'
  spec.add_runtime_dependency 'activemodel', '>= 3.1'
  spec.add_runtime_dependency 'actionpack', '>= 3.1'
  spec.add_runtime_dependency 'multi_json'
  spec.add_runtime_dependency 'typhoeus'
  spec.add_runtime_dependency 'bunny', '~> 0.9.0.pre13'
  spec.add_runtime_dependency 'rack'

  spec.add_development_dependency 'bundler', '~> 1.3'
end
