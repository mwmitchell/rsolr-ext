require 'test_unit_test_case'
require File.join(File.dirname(__FILE__), '..', 'lib', 'rsolr-ext')
require 'helper'

class RSolrExtModelTest < Test::Unit::TestCase
  
  class Metaphor
    
    include RSolr::Ext::Model
    
    def author
      self[:author_name]
    end
    
  end
  
  test "" do
    result = Metaphor.find :qt=>:search
    result.docs.each do |d|
      puts d.author
    end
  end
  
end