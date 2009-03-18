require 'test_unit_test_case'
require File.join(File.dirname(__FILE__), '..', 'lib', 'rsolr-ext')
require 'helper'

class RSolrExtResponseTest < Test::Unit::TestCase
  
  test 'base response class' do
    raw_response = eval(mock_query_response)
    r = RSolr::Ext::Response::Base.new(raw_response)
    assert r.respond_to?(:header)
    assert r.ok?
  end
  
  test 'standard response class' do
    raw_response = eval(mock_query_response)
    r = RSolr::Ext::Response::Standard.new(raw_response)
    assert r.respond_to?(:response)
    assert r.ok?
    assert_equal 10, r[:response][:docs].size
    assert_equal 'EXPLICIT', r[:responseHeader][:params][:echoParams]
    assert_equal 1, r[:response][:docs].previous_page
    assert_equal 1, r[:response][:docs].next_page
    #
    assert r[:response][:docs].kind_of?(RSolr::Ext::Response::Pageable)
    assert r.kind_of?(RSolr::Ext::Response::Facetable)
  end
  
  test 'standard response doc ext methods' do
    raw_response = eval(mock_query_response)
    r = RSolr::Ext::Response::Standard.new(raw_response)
    doc = r.docs.first
    assert doc.has?(:cat, /^elec/)
    assert ! doc.has?(:cat, 'elec')
    assert doc.has?(:cat, 'electronics')
    
    assert 'electronics', doc.get(:cat)
    assert_nil doc.get(:xyz)
    assert_equal 'def', doc.get(:xyz, :default=>'def')
  end
  
end