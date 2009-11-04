# add this directory to the load path if it hasn't already been added

lambda { |base|
  $: << base unless $:.include?(base) || $:.include?(File.expand_path(base))
}.call(File.dirname(__FILE__))

require 'mash' unless defined?(Mash)

unless Hash.respond_to?(:to_mash)
  class Hash
    def to_mash
      Mash.new(self)
    end
  end
end

require 'rubygems'
require 'rsolr'

module RSolr
  
  module Ext
    
    VERSION = '0.9.6.5'
    
    autoload :Connection, 'rsolr-ext/connection.rb'
    autoload :Doc, 'rsolr-ext/doc.rb'
    autoload :Request, 'rsolr-ext/request.rb'
    autoload :Response, 'rsolr-ext/response.rb'
    autoload :Model, 'rsolr-ext/model.rb'
    
    # c = RSolr::Ext.connect
    # c.find(:q=>'*:*').docs.size
    def self.connect(*args)
      connection = RSolr.connect(*args)
      connection.extend RSolr::Ext::Connection
      connection
    end
    
  end
  
end