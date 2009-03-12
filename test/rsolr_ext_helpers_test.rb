require 'test_unit_test_case'
require File.join(File.dirname(__FILE__), '..', 'lib', 'rsolr_ext')

class RSolrExtHelpersTest < Test::Unit::TestCase
  
  H = Object.new
  H.extend RSolrExt::Helpers
  
  test 'prep_value' do
    value = 'the man'
    assert_equal 'the man', H.prep_value(value, false)
    assert_equal "\"the man\"", H.prep_value(value, true)
  end
  
  test 'build_query' do
    assert_equal 'testing', H.build_query('testing')
    assert_equal '"testing"', H.build_query('testing', :quote=>true)
    assert_equal 'testing again', H.build_query(['testing', 'again'])
    assert_equal '"testing" "again"', H.build_query(['testing', 'again'], :quote=>true)
    assert_equal 'name:whatever', H.build_query({:name=>'whatever'})
    assert_equal 'name:"whatever"', H.build_query({:name=>'whatever'}, :quote=>true)
    assert_equal 'sam name:whatever i am', H.build_query(['sam', {:name=>'whatever'}, 'i', 'am'])
    assert_equal 'testing AND blah', H.build_query(['testing', 'blah'], :join=>' AND ')
  end
  
end