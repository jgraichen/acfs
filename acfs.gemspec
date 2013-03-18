# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'acfs/version'

Gem::Specification.new do |spec|
  spec.name          = "acfs"
  spec.version       = Acfs::VERSION
  spec.authors       = ['Jan Graichen']
  spec.email         = %w(jg@altimos.de)
  spec.description   = %q{API Client For Services}
  spec.summary       = %q{An abstract API base client for service oriented application.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = %w(lib)

  spec.add_dependency 'activesupport'

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake'
end
