require 'test_unit_test_case'
require File.join(File.dirname(__FILE__), '..', 'lib', 'rsolr_ext')

class RSolrExtTest < Test::Unit::TestCase
  
  test 'the :per_page and :page params from the Request::Select::Standard mapper' do
    
    select_params = RSolrExt::Request::Select::Standard.new
    select_params[:page] = 1
    select_params[:per_page] = 10
    
    # convert to solr params
    params = select_params.to_solr
    
    # make sure the non-solr keys have been removed
    assert_nil params[:per_page]
    assert_nil params[:page]
    
    # rows and start should now be mapped correctly
    assert_equal 10, params[:rows]
    assert_equal 0, params[:start]
    
    # the :rows and :start keys should be the only keys
    assert_equal 2, params.keys.size
  end
  
  test 'the :q and :phrases params from the Request::Select::Standard mapper' do
    select_params = RSolrExt::Request::Select::Standard.new
    select_params[:q] = 'mp3'
    select_params[:phrases] = {:manu=>'Apple'}
    
    params = select_params.to_solr
    
    assert_nil params[:phrases]
    
    assert_equal 'mp3 manu:"Apple"', params[:q]
    
    assert_equal 1, params.keys.size
  end
  
  test 'the :fq and :filters params from the Request::Select::Standard mapper' do
    select_params = RSolrExt::Request::Select::Standard.new
    select_params[:fq] = 'price:[50 TO 200]'
    select_params[:filters] = {:manu=>'Apple'}
    
    params = select_params.to_solr
    
    assert_nil params[:filters]
    
    assert_equal 'price:[50 TO 200] manu:Apple', params[:fq]
    
    assert_equal 1, params.keys.size
  end
  
  test 'the :fq, :filters and :filter_phrases params from the Request::Select::Standard mapper' do
    select_params = RSolrExt::Request::Select::Standard.new
    select_params[:fq] = 'price:[50 TO 200]'
    select_params[:filters] = {:manu=>'Apple'}
    select_params[:phrase_filters] = {:name=>'iPod'}
    
    params = select_params.to_solr
    
    assert_nil params[:filters]
    assert_nil params[:phrase_filters]
    
    assert_equal 'price:[50 TO 200] manu:Apple name:"iPod"', params[:fq]
    
    assert_equal 1, params.keys.size
  end
  
  test 'the :facets param from the Request::Select::Standard mapper' do
    select_params = RSolrExt::Request::Select::Standard.new
    select_params[:facets] = {
      :queries => 'price:[50 TO 200]',
      :fields=>['manu', 'price_range']
    }
    params = select_params.to_solr
  end
  
end