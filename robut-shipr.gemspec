# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'robut-plugin/version'

Gem::Specification.new do |spec|
  spec.name          = "robut-shipr"
  spec.version       = RobutPlugin::VERSION
  spec.authors       = ["Eric J. Holmes"]
  spec.email         = ["eric@ejholmes.net"]
  spec.description   = %q{A Robut plugin for shipr}
  spec.summary       = %q{A Robut plugin for shipr}
  spec.homepage      = "https://github.com/ejholmes/robut-shipr"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "robut"
  spec.add_dependency "json"
  spec.add_dependency "httparty"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "webmock"
end
