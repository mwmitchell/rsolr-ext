# include this module into a plain ruby class:
# class Book
#   include RSolr::Ext::Model
#   connection = RSolr::Ext.connect
#   default_params = {:phrase_filters=>'type:book'}
# end
# 
# Then:
# number_10 = Book.find_by_id(10)
#
module RSolr::Ext::Model

  # Class level methods for altering object instances
  module Callbacks
    
    # method that only accepts a block
    # The block is executed when an object is created via #new -> SolrDoc.new
    # The blocks scope is the instance of the object.
    def after_initialize(&blk)
      hooks << blk
    end
    
    # Removes the current set of after_initialize blocks.
    # You would use this if you wanted to open a class back up,
    # but clear out the previously defined blocks.
    def clear_after_initialize_blocks!
      @hooks = []
    end
    
    # creates the @hooks container ("hooks" are blocks or procs).
    # returns an array
    def hooks
      @hooks ||= []
    end
    
  end

  #
  # Findable is a module that gets mixed into the SolrDocument class object.
  # These methods will be available through the class like: SolrDocument.find and SolrDocument.find_by_id
  #
  module Findable
  
    attr_accessor :connection, :default_params
    
    def connection
      @connection ||= RSolr::Ext.connect
    end
    
    # this method decorates the connection find method
    # and then creates new instance of the class that uses this module.
    def find(*args)
      decorate_response_docs connection.find(*args)
    end
    
    # this method decorates the connection find_by_id method
    # and then creates new instance of the class that uses this module.
    def find_by_id(id, solr_params={}, opts={})
      decorate_response_docs connection.find_by_id(id, solr_params, opts)
    end
  
    protected
  
    def decorate_response_docs response
      response['response']['docs'].map!{|d| self.new d }
      response
    end
  
  end
  
  # Called by Ruby Module API
  # extends this *class* object
  def self.included(base)
    base.extend Callbacks
    base.extend Findable
    base.send :include, RSolr::Ext::Doc
  end
  
  # The original object passed in to the #new method
  attr :_source
  
  # Constructor **for the class that is getting this module included**
  # source_doc should be a hash or something similar
  # calls each of after_initialize blocks
  def initialize(source_doc={})
    @_source = source_doc.to_mash
    self.class.hooks.each do |h|
      instance_eval &h
    end
  end
  
  # the wrapper method to the @_source object.
  # If a method is missing, it gets sent to @_source
  # with all of the original params and block
  def method_missing(m, *args, &b)
    @_source.send(m, *args, &b)
  end
  
end