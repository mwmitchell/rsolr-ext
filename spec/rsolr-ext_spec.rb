require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe RSolr::Ext do
  
  context RSolr::Client do
    
    let(:client){RSolr.connect "http://localhost:9999/solr"}
    
    it 'should now have a #find method' do
      client.should respond_to(:find)
    end
    
    it 'should produce results from the #find method' do
      c = client
      c.should_receive(:send_request).
        with('select', :params => {:rows=>10, :start=>20, :q=>"*:*"}).
          and_return({'response'=>{'docs' => []}, 'responseHeader' => {}})
      response = c.find :params => {:page=>3, :per_page=>10, :q=>'*:*'}
      response.should be_a(Mash)
    end
    
    it 'should call the #find method with a custom request handler' do
      c = client
      expected_response = {'response'=>{'docs' => []}, 'responseHeader' => {}}
      # ok this is hacky... the raw method needs to go into a mixin dude
      def expected_response.request
        {:path => 'select'}
      end
      c.should_receive(:send_request).
        with('select', :params => {:q=>'*:*'}).
          and_return(expected_response)
      response = c.find 'select', :params => {:q=>'*:*'}
      response.request[:path].should == "select"
    end
    
    it 'should be ok' do
      c = client
      c.should_receive(:send_request).
        with('select', :params => {:q=>'*:*'}).
          and_return({'response'=>{'docs' => []}, 'responseHeader' => {'status'=>0}})
      response = c.find :params => {:q=>'*:*'}
      response.should respond_to(:ok?)
      response.ok?.should == true
    end
    
    it 'should call the #luke method' do
      c = client
      c.should_receive(:send_request).
        with('admin/luke', :params => {:numTerms => 0}).
          and_return({"fields"=>nil, "index"=>nil, "info" => nil})
      info = c.luke
      info.should be_a(Mash)
      info.should have_key('fields')
      info.should have_key('index')
      info.should have_key('info')
    end
    
    it 'should forwad #ping? call ping' do
      client.should_receive(:ping).
        and_return( :params => { :wt => :ruby },
                    :status_code => 200,
                    :body => "{'responseHeader'=>{'status'=>0,'QTime'=>44,'params'=>{'echoParams'=>'all','echoParams'=>'all','q'=>'solrpingquery','qt'=>'standard','wt'=>'ruby'}},'status'=>'OK'}" )
      client.ping?
    end
    
  end
  
  context 'requests' do

    it 'should create a valid request' do
      solr_params = RSolr::Ext::Request.map(
        :phrases=>{:name=>'This is a phrase'},
        :filters=>['test', {:price=>(1..10)}],
        :phrase_filters=>{:manu=>['Apple']},
        :queries=>'ipod',
        :facets=>{:fields=>['cat', 'blah']},
        :spellcheck => true
      )
      ["test", "price:[1 TO 10]", "manu:\"Apple\""].should == solr_params[:fq]
      solr_params[:q].should == "ipod name:\"This is a phrase\""
      solr_params['facet.field'].should == ['cat', 'blah']
      solr_params[:facet].should == true
    end
    
    it 'should map fq using the phrase_filters mapping' do
      solr_params = RSolr::Ext::Request.map(
        :phrase_filters=>{:manu=>['Apple', 'ASG'], :color=>['red', 'blue']}
      )
      
      solr_params[:fq].size.should == 4
      solr_params[:fq].should include("color:\"red\"")
      solr_params[:fq].should include("color:\"blue\"")
      solr_params[:fq].should include("manu:\"Apple\"")
      solr_params[:fq].should include("manu:\"ASG\"")
      
    end
    
    it 'should map :filters and :phrase_filters while keeping an existing :fq' do
      solr_params = RSolr::Ext::Request.map(
        :fq => 'blah blah',
        :phrase_filters=>{:manu=>['Apple', 'ASG'], :color=>['red', 'blue']}
      )
      
      solr_params[:fq].size.should == 5
      solr_params[:fq].should include("blah blah")
      solr_params[:fq].should include("color:\"red\"")
      solr_params[:fq].should include("color:\"blue\"")
      solr_params[:fq].should include("manu:\"Apple\"")
      solr_params[:fq].should include("manu:\"ASG\"")
    end

    it 'should map arrays of ranges in :phrase_filters' do
        solr_params = RSolr::Ext::Request.map(
          :phrase_filters=>{:range=>[1940..2020]}
        )

        solr_params[:fq].size.should == 1
        solr_params[:fq].should include("range:[1940 TO 2020]")
    end
    
  end
  
  context 'response' do
    
    def create_response
      raw_response = eval(mock_query_response)
      RSolr::Ext::Response::Base.new(raw_response, '/select', raw_response['params'])
    end
    
    it 'should create a valid response' do
      r = create_response
      r.should respond_to(:header)
      r.ok?.should == true
    end
    
    it 'should create a valid response class' do
      r = create_response
      r.should respond_to(:response)
      r.ok?.should == true
      r.docs.size.should == 11
      r.params[:echoParams].should == 'EXPLICIT'
      r.should be_a(RSolr::Ext::Response::Facets)
    end
    
    it 'should create a doc with rsolr-ext methods' do
      r = create_response
      
      doc = r.docs.first
      doc.has?(:cat, /^elec/).should == true
      doc.has?(:cat, 'elec').should_not == true
      doc.has?(:cat, 'electronics').should == true
      
      doc.get(:cat).should == 'electronics, hard drive'
      doc.get(:xyz).should == nil
      doc.get(:xyz, :default=>'def').should == 'def'
    end
    
    it 'should provide facet helpers' do
      r = create_response
      r.facets.size.should == 2
    
      field_names = r.facets.collect{|facet|facet.name}
      field_names.include?('cat').should == true
      field_names.include?('manu').should == true
      
      first_facet = r.facets.first
      first_facet.name.should == 'cat'
      
      first_facet.items.size.should == 10
      
      expected = "electronics - 14, memory - 3, card - 2, connector - 2, drive - 2, graphics - 2, hard - 2, monitor - 2, search - 2, software - 2"
      received = first_facet.items.collect do |item|
        item.value + ' - ' + item.hits.to_s
      end.join(', ')
      
      expected.should == received
      
      r.facets.each do |facet|
        facet.respond_to?(:name).should == true
        facet.items.each do |item|
          item.respond_to?(:value).should == true
          item.respond_to?(:hits).should == true
        end
      end
      
    end
    
    it 'should return the correct value when calling facet_by_field_name' do
      r = create_response
      facet = r.facet_by_field_name('cat')
      facet.name.should == 'cat'
    end
    
    it 'should provide the responseHeader params' do
      raw_response = eval(mock_query_response)
      raw_response['responseHeader']['params']['test'] = :test
      r = RSolr::Ext::Response::Base.new(raw_response, '/catalog', raw_response['params'])
      r.params['test'].should == :test
    end
    
    it 'should provide the solr-returned params and "rows" should be 11' do
      raw_response = eval(mock_query_response)
      r = RSolr::Ext::Response::Base.new(raw_response, '/catalog', {})
      r.params[:rows].to_s.should == '11'
    end
    
    it 'should provide the ruby request params if responseHeader["params"] does not exist' do
      raw_response = eval(mock_query_response)
      raw_response.delete 'responseHeader'
      r = RSolr::Ext::Response::Base.new(raw_response, '/catalog', :params => {:rows => 999})
      r.params[:rows].to_s.should == '999'
    end
    
  end
  
end
