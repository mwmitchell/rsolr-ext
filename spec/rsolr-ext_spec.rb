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
  
end