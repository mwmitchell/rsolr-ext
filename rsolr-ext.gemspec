Gem::Specification.new do |s|
  s.name = "rsolr-ext"
  s.version = "0.9.6.5"
  s.date = "2009-11-04"
  
  s.summary = "An extension lib for RSolr"
  s.email = "goodieboy@gmail.com"
  s.homepage = "http://github.com/mwmitchell/rsolr-ext"
  s.description = "An extension lib for RSolr"
  s.has_rdoc = true
  s.authors = ["Matt Mitchell"]
  s.files = [
    "lib/mash.rb",
    "lib/rsolr-ext/connection.rb",
    "lib/rsolr-ext/doc.rb",
    "lib/rsolr-ext/model.rb",
    "lib/rsolr-ext/request.rb",
    "lib/rsolr-ext/response/docs.rb",
    "lib/rsolr-ext/response/facets.rb",
    "lib/rsolr-ext/response/spelling.rb",
    "lib/rsolr-ext/response.rb",
    "lib/rsolr-ext.rb",
    "LICENSE",
    "README.rdoc",
    "rsolr-ext.gemspec"
	]
	s.test_files = [
	  'test/connection_test.rb',
	  'test/request_test.rb',
	  'test/response_test.rb',
	  'test/test_unit_test_case.rb',
	  'test/helper.rb'
	]
	
	s.extra_rdoc_files = %w(LICENSE README.rdoc)
	
	s.add_dependency("mwmitchell-rsolr", [">= 0.9.6"])
	
end