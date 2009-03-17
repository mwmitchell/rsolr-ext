require 'test_unit_test_case'
require File.join(File.dirname(__FILE__), '..', 'lib', 'rsolr-ext')

class RSolrExtRequestTest < Test::Unit::TestCase
  
  def testable_hash
    {:name=>'Sam', :age=>90, :kids=>['Fred', 'Betty'], :favorites=>{:red=>1, :blue=>9}}
  end
  
  test 'the default behavior of a hash, after methodize!' do
    my_hash = testable_hash
    
    original_methods = my_hash.methods
    key_count = my_hash.keys.size
    
    RSolr::Ext::HashMethodizer.methodize!(my_hash)
    
    assert_equal key_count, my_hash.keys.size
    
    [:name, :age, :kids, :favorites].each do |k|
      assert my_hash.keys.include?(k)
    end
    
    assert_equal 1, my_hash[:favorites][:red]
    assert_equal 9, my_hash[:favorites][:blue]
    
    assert_equal Hash, my_hash.class
    
    # make sure that the difference in method size is the size of the keys in my_hash
    assert_equal my_hash.methods.size - key_count, original_methods.size
  end
  
  test 'the method accessors on a modified hash' do
    
    my_hash = testable_hash
    
    assert_raise NoMethodError do
      my_hash.favorites
    end
    
    RSolr::Ext::HashMethodizer.methodize!(my_hash)
    
    assert_equal my_hash[:name], my_hash.name
    assert_equal my_hash[:age], my_hash.age
    assert_equal my_hash[:kids], my_hash.kids
    assert_equal my_hash[:favorites], my_hash.favorites
    
    assert_equal my_hash[:favorites][:blue], my_hash.favorites.blue
    assert_equal my_hash[:favorites][:red], my_hash.favorites.red
    
  end
  
end