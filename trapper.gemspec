# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'trapper/version'

Gem::Specification.new do |spec|
  spec.name          = "trapper"
  spec.version       = Trapper::VERSION
  spec.authors       = ["Matti Paksula"]
  spec.email         = ["matti.paksula@iki.fi"]

  spec.summary       = %q{Debugging live Ruby objects with control+c}
  spec.description   = %q{}
  spec.homepage      = "http://www.github.com/matti/trapper"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rspec-autotest", "~> 1.0"
  spec.add_development_dependency "ZenTest", "~> 4.11"

  spec.add_development_dependency "kommando"
  spec.add_development_dependency "byebug"
end
