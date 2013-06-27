# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'rsolr-ext/version'

Gem::Specification.new do |s|
  s.name = %q{rsolr-ext}
  s.version = RSolr::Ext::VERSION

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Matt Mitchell", "James Davidson", "Chris Beer", "Jason Ronallo", "Eric Lindvall", "Andreas Kemkes"]
  s.date = %q{2011-06-08}
  s.description = %q{A query/response extension lib for RSolr}
  s.email = %q{goodieboy@gmail.com}
  s.homepage = %q{http://github.com/mwmitchell/rsolr-ext}
  s.summary = %q{A query/response extension lib for RSolr}
  s.files         = `git ls-files`.split($/)
  s.executables   = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths = ["lib"]


  s.add_dependency 'rsolr', ">= 1.0.1"
  s.add_development_dependency 'rake', '~> 0.9.2'
  s.add_development_dependency 'rdoc', '~> 3.9.4'
  s.add_development_dependency 'rspec', '~> 2.6.0'
end

