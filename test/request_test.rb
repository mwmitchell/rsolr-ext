class RSolrExtRequestTest < Test::Unit::TestCase
  
  test 'standard request' do
    solr_params = RSolr::Ext::Request.map(
      :page=>'2',
      :per_page=>'10',
      :phrases=>{:name=>'This is a phrase'},
      :filters=>['test', {:price=>(1..10)}],
      :phrase_filters=>{:manu=>['Apple']},
      :queries=>'ipod',
      :facets=>{:fields=>['cat', 'blah']},
      :spellcheck => true
    )
    assert_equal ["test", "price:[1 TO 10]", "manu:\"Apple\""], solr_params[:fq]
    assert_equal 10, solr_params[:start]
    assert_equal 10, solr_params[:rows]
    assert_equal "ipod name:\"This is a phrase\"", solr_params[:q]
    assert_equal ['cat', 'blah'], solr_params['facet.field']
    assert_equal true, solr_params[:facet]
  end
  
  test 'fq param using the phrase_filters mapping' do
    solr_params = RSolr::Ext::Request.map(
      :phrase_filters=>{:manu=>['Apple', 'ASG'], :color=>['red', 'blue']}
    )
    
    assert_equal 4, solr_params[:fq].size
    assert solr_params[:fq].include?("color:\"red\"")
    assert solr_params[:fq].include?("color:\"blue\"")
    assert solr_params[:fq].include?("manu:\"Apple\"")
    assert solr_params[:fq].include?("manu:\"ASG\"")
    
  end
  
  test ':filters and :phrase_filters will play nice with :fq' do
    solr_params = RSolr::Ext::Request.map(
      :fq => 'blah blah',
      :phrase_filters=>{:manu=>['Apple', 'ASG'], :color=>['red', 'blue']}
    )
    expected = {:fq=>["blah blah", "color:\"red\"", "color:\"blue\"", "manu:\"Apple\"", "manu:\"ASG\""]}
    
    assert_equal 5, solr_params[:fq].size
    assert solr_params[:fq].include?("blah blah")
    assert solr_params[:fq].include?("color:\"red\"")
    assert solr_params[:fq].include?("color:\"blue\"")
    assert solr_params[:fq].include?("manu:\"Apple\"")
    assert solr_params[:fq].include?("manu:\"ASG\"")
  end
  
end