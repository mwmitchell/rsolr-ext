require 'test_unit_test_case'
require File.join(File.dirname(__FILE__), '..', 'lib', 'rsolr-ext')
require 'helper'

class RSolrExtModelTest < Test::Unit::TestCase
  
  class Book
    
    include RSolr::Ext::Model
    
    def self.find_by_author(author, params={})
      p = {:queries=>author, :qf=>:author_name, :qt=>:search}.merge(params)
      find p
    end
    
    def view
      'blah'
    end
    
  end
  
  test "" do
    result = Book.find_by_author 'Jeffreys'
    result.docs.each do |d|
      puts d.view
    end
  end
  
end