require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe RSolr::Ext do
  
  context RSolr::Client do
    
    let(:connection){RSolr.connect}
    
    it 'should now have a #find method' do
      connection.should respond_to(:find)
    end
    
    it 'should produce results from the #find method' do
      response = connection.find :page=>3, :per_page=>10, :q=>'*:*'#, :page=>1, :per_page=>10
      response.should be_a(Mash)
    end
    
    it 'the #find method with a custom request handler' do
      response = connection.find '/select', :q=>'*:*'
      response.raw[:path].should match(/\/select/)
    end
    
    it 'the response' do
      response = connection.find :q=>'*:*'
      response.should respond_to(:ok?)
      response.ok?.should == true
    end
    
    it 'the #luke method' do
      info = connection.luke
      info.should be_a(Mash)
      info.should have_key('fields')
      info.should have_key('index')
      info.should have_key('info')
    end
  
  end
  
  context 'requests' do

    # test 'standard request' do
    #   solr_params = RSolr::Ext::Request.map(
    #     :page=>'2',
    #     :per_page=>'10',
    #     :phrases=>{:name=>'This is a phrase'},
    #     :filters=>['test', {:price=>(1..10)}],
    #     :phrase_filters=>{:manu=>['Apple']},
    #     :queries=>'ipod',
    #     :facets=>{:fields=>['cat', 'blah']},
    #     :spellcheck => true
    #   )
    #   assert_equal ["test", "price:[1 TO 10]", "manu:\"Apple\""], solr_params[:fq]
    #   assert_equal 10, solr_params[:start]
    #   assert_equal 10, solr_params[:rows]
    #   assert_equal "ipod name:\"This is a phrase\"", solr_params[:q]
    #   assert_equal ['cat', 'blah'], solr_params['facet.field']
    #   assert_equal true, solr_params[:facet]
    # end
    # 
    # test 'fq param using the phrase_filters mapping' do
    #   solr_params = RSolr::Ext::Request.map(
    #     :phrase_filters=>{:manu=>['Apple', 'ASG'], :color=>['red', 'blue']}
    #   )
    # 
    #   assert_equal 4, solr_params[:fq].size
    #   assert solr_params[:fq].include?("color:\"red\"")
    #   assert solr_params[:fq].include?("color:\"blue\"")
    #   assert solr_params[:fq].include?("manu:\"Apple\"")
    #   assert solr_params[:fq].include?("manu:\"ASG\"")
    # 
    # end
    # 
    # test ':filters and :phrase_filters will play nice with :fq' do
    #   solr_params = RSolr::Ext::Request.map(
    #     :fq => 'blah blah',
    #     :phrase_filters=>{:manu=>['Apple', 'ASG'], :color=>['red', 'blue']}
    #   )
    #   expected = {:fq=>["blah blah", "color:\"red\"", "color:\"blue\"", "manu:\"Apple\"", "manu:\"ASG\""]}
    # 
    #   assert_equal 5, solr_params[:fq].size
    #   assert solr_params[:fq].include?("blah blah")
    #   assert solr_params[:fq].include?("color:\"red\"")
    #   assert solr_params[:fq].include?("color:\"blue\"")
    #   assert solr_params[:fq].include?("manu:\"Apple\"")
    #   assert solr_params[:fq].include?("manu:\"ASG\"")
    # end
    
  end
  
  context 'response' do
    # 
    # def create_response
    #   raw_response = eval(mock_query_response)
    #   RSolr::Ext::Response::Base.new(raw_response, '/select', raw_response['params'])
    # end
    # 
    # test 'base response class' do
    #   r = create_response
    #   assert r.respond_to?(:header)
    #   assert r.ok?
    # end
    # 
    # test 'pagination related methods' do
    #   r = create_response
    #   assert_equal 11, r.rows
    #   assert_equal 26, r.total
    #   assert_equal 0, r.start
    #   assert_equal 11, r.docs.per_page
    # end
    # 
    # test 'standard response class' do
    #   r = create_response
    # 
    #   assert r.respond_to?(:response)
    #   assert r.ok?
    #   assert_equal 11, r.docs.size
    #   assert_equal 'EXPLICIT', r.params[:echoParams]
    #   assert_equal 1, r.docs.previous_page
    #   assert_equal 2, r.docs.next_page
    #   #
    #   assert r.kind_of?(RSolr::Ext::Response::Docs)
    #   assert r.kind_of?(RSolr::Ext::Response::Facets)
    # end
    # 
    # test 'standard response doc ext methods' do
    #   r = create_response
    #   doc = r.docs.first
    #   assert doc.has?(:cat, /^elec/)
    #   assert ! doc.has?(:cat, 'elec')
    #   assert doc.has?(:cat, 'electronics')
    # 
    #   assert 'electronics', doc.get(:cat)
    #   assert_nil doc.get(:xyz)
    #   assert_equal 'def', doc.get(:xyz, :default=>'def')
    # end
    # 
    # test 'Response::Standard facets' do
    #   r = create_response
    #   assert_equal 2, r.facets.size
    # 
    #   field_names = r.facets.collect{|facet|facet.name}
    #   assert field_names.include?('cat')
    #   assert field_names.include?('manu')
    # 
    #   first_facet = r.facets.first
    #   assert_equal 'cat', first_facet.name
    # 
    #   assert_equal 10, first_facet.items.size
    # 
    #   expected = first_facet.items.collect do |item|
    #     item.value + ' - ' + item.hits.to_s
    #   end.join(', ')
    #   assert_equal "electronics - 14, memory - 3, card - 2, connector - 2, drive - 2, graphics - 2, hard - 2, monitor - 2, search - 2, software - 2", expected
    # 
    #   r.facets.each do |facet|
    #     assert facet.respond_to?(:name)
    #     facet.items.each do |item|
    #       assert item.respond_to?(:value)
    #       assert item.respond_to?(:hits)
    #     end
    #   end
    # 
    # end
    # 
    # test 'response::standard facet_by_field_name' do
    #   r = create_response
    #   facet = r.facet_by_field_name('cat')
    #   assert_equal 'cat', facet.name
    # end
    # 
    # test 'the response provides the responseHeader params' do
    #   raw_response = eval(mock_query_response)
    #   raw_response['responseHeader']['params']['test'] = :test
    #   r = RSolr::Ext::Response::Base.new(raw_response, '/catalog', raw_response['params'])
    #   assert_equal :test, r.params['test']
    # end
    # 
    # test 'the response provides the solr-returned params and rows should be 11' do
    #   raw_response = eval(mock_query_response)
    #   r = RSolr::Ext::Response::Base.new(raw_response, '/catalog', {})
    #   assert_equal '11', r.params[:rows].to_s
    # end
    # 
    # test 'the response provides the ruby request params if responseHeader["params"] does not exist' do
    #   raw_response = eval(mock_query_response)
    #   raw_response.delete 'responseHeader'
    #   r = RSolr::Ext::Response::Base.new(raw_response, '/catalog', :rows => 999)
    #   assert_equal '999', r.params[:rows].to_s
    # end
    
  end
  
end