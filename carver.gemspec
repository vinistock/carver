# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'carver/version'

Gem::Specification.new do |spec|
  spec.name          = 'carver'
  spec.version       = Carver::VERSION
  spec.authors       = ['Vinicius Stock']
  spec.email         = ['vinicius.stock@outlook.com']

  spec.summary       = %q{A Ruby CSS post processor for removing unused definitions}
  spec.description   = %q{This gem registers a post processor for your Rails project to remove unused CSS classes and definitions}
  spec.homepage      = 'https://github.com/vinistock/carver'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end

  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.14'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.5'
  spec.add_development_dependency 'simplecov', '~> 0.14'
  spec.add_development_dependency 'codeclimate-test-reporter', '~> 1.0'
  spec.add_development_dependency 'byebug', '~> 9.0'
end
