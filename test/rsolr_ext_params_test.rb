require 'test_unit_test_case'
require File.join(File.dirname(__FILE__), '..', 'lib', 'rsolr_ext')

class RSolrExtParamsTest < Test::Unit::TestCase
  
  H = RSolrExt::Params
  
  test 'prep_value' do
    value = 'the man'
    assert_equal 'the man', H.escape(value, false)
    assert_equal "\"the man\"", H.escape(value, true)
  end
  
  test 'build_query' do
    assert_equal ['name:whatever'], H.create_fielded_queries({:name=>'whatever'})
    assert_equal ['name:"whatever"'], H.create_fielded_queries({:name=>'whatever'}, true)
    assert_equal ['name:testing', 'name:blah'], H.create_fielded_queries({:name=>['testing', 'blah']})
  end
  
end