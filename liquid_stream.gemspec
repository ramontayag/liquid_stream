# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'liquid_stream/version'

Gem::Specification.new do |spec|
  spec.name          = "liquid_stream"
  spec.version       = LiquidStream::VERSION
  spec.authors       = ["Ramon Tayag"]
  spec.email         = ["ramon.tayag@gmail.com"]
  spec.description   = %q{Allows chaining of context aware Liquid drops}
  spec.summary       = %q{Allow a more Ruby-like interface to Liquid drops with context awareness}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", '~> 2.13'
  spec.add_development_dependency "activemodel", '~> 3.2'
  spec.add_development_dependency "capybara", '~> 2.1'
  spec.add_dependency 'liquid', '~> 2.2'
  spec.add_dependency 'activesupport', '>= 3.0.0'
end
