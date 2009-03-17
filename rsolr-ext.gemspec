Gem::Specification.new do |s|
	s.name = "rsolr-ext"
	s.version = "0.5.0"
	s.date = "2009-03-17"
	s.summary = "An extension lib for RSolr"
	s.email = "goodieboy@gmail.com"
	s.homepage = "http://github.com/mwmitchell/rsolr_ext"
	s.description = "An extension lib for RSolr"
	s.has_rdoc = true
	s.authors = ["Matt Mitchell"]
	s.files = [
    
    "lib/core_ext.rb",
    "lib/mash.rb",
    
    "lib/rsolr-ext/hash_methodizer",
    
    "lib/rsolr-ext/request/dismax.rb",
    "lib/rsolr-ext/request/standard.rb",
    "lib/rsolr-ext/request.rb",
    
    "lib/rsolr-ext/response/doc_ext.rb",
    "lib/rsolr-ext/response/facet_paginator.rb",
    "lib/rsolr-ext/response/facetable.rb",
    "lib/rsolr-ext/response/pageable.rb",
    "lib/rsolr-ext/response.rb",
    
    "lib/rsolr-ext.rb",
    
    "LICENSE",
    "README.rdoc",
    "rsolr-ext.gemspec"
	]
	s.test_files = ['test/request_test.rb', 'test/response_test.rb', 'test/test_unit_test_case.rb', 'test/helper.rb']
	s.extra_rdoc_files = %w(LICENSE README.rdoc)
end