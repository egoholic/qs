# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'qs/version'

Gem::Specification.new do |spec|
  spec.name          = "qs"
  spec.version       = Qs::VERSION
  spec.authors       = ["Vladimir Melnik"]
  spec.email         = ["egotraumatic@gmail.com"]
  spec.summary       = %q{TODO: Write a short summary. Required.}
  spec.description   = %q{TODO: Write a longer description. Optional.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler",      "~> 1.7"
  spec.add_development_dependency "rake",         "~> 10.0"
  spec.add_development_dependency "rspec",        "~> 3.3"
  spec.add_development_dependency "mutant-rspec", "~> 0.8"
  spec.add_development_dependency "guard-rspec",  "~> 4.6"
end
