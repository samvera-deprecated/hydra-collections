# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'hydra/collections/version'

Gem::Specification.new do |spec|
  spec.name          = "hydra-collections"
  spec.version       = Hydra::Collections::VERSION
  spec.authors       = ["Carolyn Cole"]
  spec.email         = ["cam156@psu.edu"]
  spec.description   = "A rails engine for managing Hydra Collections"
  spec.summary       = "A rails engine for managing Hydra Collections"
  spec.homepage      = "https://github.com/projecthydra/hydra-collections"
  spec.license       = "APACHE2"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'hydra-head', '~> 9.9'
  spec.add_dependency 'active-fedora', '~> 9.9'
  spec.add_dependency 'deprecation', '~> 0.1'
  spec.add_dependency 'blacklight', '~> 6.0'
  spec.add_dependency 'hydra-works', '~> 0.4'
  spec.add_dependency 'rdf', '~> 1.99'
  spec.add_dependency 'rdf-vocab', '~> 0'

  spec.add_development_dependency 'engine_cart', '~> 0.8'
  spec.add_development_dependency 'rspec-rails', '~> 3.1'
  spec.add_development_dependency 'rubocop', '~> 0.39'
  spec.add_development_dependency 'rubocop-rspec', '>= 1.4.1'
end
