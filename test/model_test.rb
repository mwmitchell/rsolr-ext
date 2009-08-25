require 'test_unit_test_case'
require File.join(File.dirname(__FILE__), '..', 'lib', 'rsolr-ext')
require 'helper'

class RSolrExtModelTest < Test::Unit::TestCase
  
  class DocX
    include RSolr::Ext::Model
  end
  
  test "" do
    
  end
  
end