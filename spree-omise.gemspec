# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'spree/omise/version'

Gem::Specification.new do |spec|
  spec.name          = "spree-omise"
  spec.version       = Spree::Omise::VERSION
  spec.authors       = ["Omise"]
  spec.email         = ["support@omise.co"]
  spec.description   = "Spree Omise payment gateway"
  spec.summary       = "Omise payment gateway Spree integration"
  spec.homepage      = "https://www.omise.co/"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"

  spec.add_runtime_dependency "spree"
end
