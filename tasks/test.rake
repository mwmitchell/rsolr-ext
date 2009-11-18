desc "Run basic tests"
Rake::TestTask.new("test") { |t|
  t.test_files = ['lib/rsolr-ext.rb', 'test/test_unit_test_case.rb', 'test/helper.rb']
  t.pattern = 'test/*_test.rb'
  t.verbose = true
  t.warning = true
}