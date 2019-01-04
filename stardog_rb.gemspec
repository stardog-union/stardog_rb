lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'stardog_rb/version'

Gem::Specification.new do |spec|
  spec.name = 'stardog_rb'
  spec.version = StardogRb::VERSION
  spec.authors = ['Cullan Springstead']
  spec.email = ['cullan.springstead@stardog.com']
  spec.summary = 'Stardog_rb: Ruby bindings for Stardog'
  spec.homepage = 'https://www.stardog.com'
  spec.license = 'Apache License'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/stardog-union/stardog_rb'

  spec.files = Dir['lib/**/*.rb'] + ['LICENSE.txt']
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'minitest', '~> 5.0'
  spec.add_development_dependency 'rake', '~> 10.0'
end
