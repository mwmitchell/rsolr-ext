require 'test_unit_test_case'
require File.join(File.dirname(__FILE__), '..', 'lib', 'rsolr_params')

class RSolrParamsTest < Test::Unit::TestCase
  
  P = RSolr::Params
  
  class MH; include RSolr::Params::CommonHelpers; end
  
  test 'helper methods' do
    value = 'the man'
    helper = MH.new
    # prep_value
    assert_equal value, helper.prep_value(value, false)
    assert_equal "\"#{value}\"", helper.prep_value(value, true)
    # build_query
    assert_equal ['testing'], helper.build_query('testing', false)
    assert_equal ['"testing"'], helper.build_query('testing', true)
    assert_equal ['testing', 'again'], helper.build_query(['testing', 'again'], false)
    assert_equal ['"testing"', '"again"'], helper.build_query(['testing', 'again'], true)
    assert_equal ['name:whatever'], helper.build_query({:name=>'whatever'}, false)
    assert_equal ['name:"whatever"'], helper.build_query({:name=>'whatever'}, true)
    assert_equal ['sam', 'name:whatever', 'i', 'am'], helper.build_query(['sam', {:name=>'whatever'}, 'i', 'am'], false)
  end
  
  # :queries and :phrase_queries -> :q mapping
  
  test 'simple :queries->:q mapping' do
    mapped_params = P.standard(
      :queries=>'testing'
    )
    expected = {:q=>'testing'}
    assert_equal expected, mapped_params
  end
  
  test 'complex :queries->:q mapping' do
    mapped_params = P.standard(
      :queries=>['one', 'blah', {:name=>'value'}]
    )
    expected = {:q=>'one blah name:value'}
    assert_equal expected, mapped_params
  end
  
  test 'simple phrase/q mapping' do
    mapped_params = P.standard(
      :phrase_queries=>['one', {:name=>'Mona'}]
    )
    expected = {:q=>'"one" name:"Mona"'}
    assert_equal expected, mapped_params
  end
  
  test 'simple :queries->:q in combination with simple :phrase_queries->:q' do
    mapped_params = P.standard(
      :queries=>'blah',
      :phrase_queries=>'hello'
    )
    expected = {:q=>'blah "hello"'}
    assert_equal expected, mapped_params
  end
  
  test 'complex :queries->:q in combination with complex :phrase_queries->:q' do
    mapped_params = P.standard(
      :queries=>['blah', {:person=>'frank'}],
      :phrase_queries=>['hello', {:name=>'frank'}]
    )
    expected = {:q=>'blah person:frank "hello" name:"frank"'}
    assert_equal expected, mapped_params
  end
  
  # :filters -> :fq mapping
  
  test 'simple filters/fq mapping' do
    mapped_params = P.standard(
      :filters=>'a filter'
    )
    expected = {:fq=>'a filter'}
    assert_equal expected, mapped_params
  end
  
  test 'complex (hash) filters/fq mapping' do
    mapped_params = P.standard(
      :filters=>{:name=>'fred'}
    )
    expected = {:fq=>'name:fred'}
    assert_equal expected, mapped_params
  end
  
  test 'simple phrase_filters/fq mapping' do
    mapped_params = P.standard(
      :phrase_filters=>'a filter'
    )
    expected = {:fq=>'"a filter"'}
    assert_equal expected, mapped_params
  end
  
  test 'complex (hash) phrase_filters/fq mapping' do
    mapped_params = P.standard(
      :phrase_filters=>{:name=>'fred'}
    )
    expected = {:fq=>'name:"fred"'}
    assert_equal expected, mapped_params
  end
  
  test 'simple :filters->:fq in combination with simple :phrase_filters->:fq' do
    mapped_params = P.standard(
      :filters=>'blah',
      :phrase_filters=>'hello'
    )
    expected = {:fq=>'blah "hello"'}
    assert_equal expected, mapped_params
  end
  
  test 'complex :filters->:fq in combination with complex :phrase_filters->:fq' do
    mapped_params = P.standard(
      :filters=>['blah', {:person=>'frank'}],
      :phrase_filters=>['hello', {:name=>'frank'}]
    )
    expected = {:fq=>'blah person:frank "hello" name:"frank"'}
    assert_equal expected, mapped_params
  end
  
  # :facets mapping
  
  
  
end