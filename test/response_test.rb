require 'test_unit_test_case'
require File.join(File.dirname(__FILE__), '..', 'lib', 'rsolr-ext')
require 'helper'

class RSolrExtResponseTest < Test::Unit::TestCase
  
  test 'base response module' do
    raw_response = eval(mock_query_response)
    r = RSolr::Ext::Response::Base.create(raw_response)
    assert r.ok?
  end
  
end