# add this directory to the load path if it hasn't already been added

require File.join(File.dirname(__FILE__), 'mash') unless defined?(Mash)

unless Hash.respond_to?(:to_mash)
  class Hash
    def to_mash
      Mash.new(self)
    end
  end
end

require 'rubygems'
require 'rsolr'

module RSolr::Ext
  
  autoload :Client, 'rsolr-ext/client.rb'
  autoload :Doc, 'rsolr-ext/doc.rb'
  autoload :Request, 'rsolr-ext/request.rb'
  autoload :Response, 'rsolr-ext/response.rb'
  autoload :Model, 'rsolr-ext/model.rb'
  
  def self.version
    @version ||= File.read(File.join(File.dirname(__FILE__), '..', 'VERSION'))
  end
  
  VERSION = self.version
  
  # modify the RSolr::Client (provides #find and #luke methods)
  RSolr::Client.class_eval do
    include RSolr::Ext::Client
  end
  
  # this is for backward compatibility: RSolr::Ext.connect
  # recommended way is to just use RSolr.connect
  def self.connect *args, &blk
    RSolr.connect *args, &blk
  end
  
end

# solr = RSolr.connect "http://localhost:8983/solr/production"
# puts solr.luke.inspect
# puts solr.ping?

# r = solr.find :method => :post, :data => {:q=>"*:*", :per_page => 1, :page => 1, :phrase_filters => {:id => "Peach::Hotel 4c2a35a5511055439900040c"}}
# puts r.request.inspect
# puts r.inspect