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
  spec.homepage      = "https://github.com/psu-stewardship/hydra-collections"
  spec.license       = "APACHE2"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "blacklight"
  spec.add_dependency "hydra-head", "~> 7.0"

  spec.add_development_dependency "engine_cart"
  spec.add_development_dependency "rspec-rails"
end
