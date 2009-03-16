Gem::Specification.new do |s|
	s.name = "rsolr-ext"
	s.version = "0.4.1"
	s.date = "2009-03-15"
	s.summary = "An extension lib for RSolr"
	s.email = "goodieboy@gmail.com"
	s.homepage = "http://github.com/mwmitchell/rsolr_ext"
	s.description = "An extension lib for RSolr"
	s.has_rdoc = true
	s.authors = ["Matt Mitchell"]
	s.files = [
	"lib/rsolr-ext.rb",
	"lib/rsolr-ext/params.rb",
	"lib/rsolr-ext/request.rb",
	"lib/rsolr-ext/request/standard.rb",
	"lib/rsolr-ext/request/dismax.rb",
	"lib/rsolr-ext/response.rb",
	"lib/rsolr-ext/response/base.rb",
	"lib/rsolr-ext/response/luke.rb",
	"lib/rsolr-ext/response/select.rb",
	"lib/rsolr-ext/response/update.rb",
	"LICENSE",
	"README.rdoc",
	"rsolr-ext.gemspec"
	]
	s.test_files = ['test/request_test.rb', 'test/response_test.rb', 'test/test_unit_test_case.rb', 'test/helper.rb']
	s.extra_rdoc_files = %w(LICENSE README.rdoc)
end