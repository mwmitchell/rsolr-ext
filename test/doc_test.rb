require 'test_unit_test_case'
require File.join(File.dirname(__FILE__), '..', 'lib', 'rsolr-ext')
require 'helper'

class RSolrExtDocTest < Test::Unit::TestCase
  
  class MyDoc
    
    include RSolr::Ext::Doc
    
  end
  
end