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
  
  # ripped from MongoMapper!
  module Pluggable
    
    def plugins
      @plugins ||= []
    end
    
    def plugin(mod)
      extend mod::ClassMethods     if mod.const_defined?(:ClassMethods)
      include mod::InstanceMethods if mod.const_defined?(:InstanceMethods)
      mod.configure(self)          if mod.respond_to?(:configure)
      plugins << mod
    end
    
  end
  
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
  # Findable is a module that gets mixed into the SolrDocument *class* object.
  # These methods will be available through the class: SolrDocument.find
  #
  module Findable
    
    attr_accessor :connection
    
    def connection
      @connection ||= RSolr::Ext.connect
    end
    
    # this method decorates the connection find method
    # and then creates new instance of the class that uses this module.
    def find *args, &block
      response = connection.find(*args)
      response.docs.map {|doc|
        d = self.new doc, response
        yield d if block_given?
        d
      }
    end
    
  end
  
  # Called by Ruby Module API
  # extends this *class* object
  def self.included(base)
    base.extend Pluggable
    base.extend Callbacks
    base.extend Findable
    base.send :include, RSolr::Ext::Doc
  end
  
  attr_reader :solr_response
  
  # The original object passed in to the #new method
  attr :_source
  
  # Constructor **for the class that is getting this module included**
  # source_doc should be a hash or something similar
  # calls each of after_initialize blocks
  def initialize(source_doc={}, solr_response=nil)
    @_source = source_doc.to_mash
    @solr_response = solr_response
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