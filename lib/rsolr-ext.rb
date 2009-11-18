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
    
    VERSION = '0.11.0'
    
    autoload :Connection, 'rsolr-ext/connection.rb'
    autoload :Doc, 'rsolr-ext/doc.rb'
    autoload :Request, 'rsolr-ext/request.rb'
    autoload :Response, 'rsolr-ext/response.rb'
    autoload :Model, 'rsolr-ext/model.rb'
    
    module Connectors
      [:connect, :direct_connect].each do |m|
        define_method m do |*args|
          RSolr.send(m, *args).extend RSolr::Ext::Connection
        end
      end
    end
    
    extend Connectors
    
  end
  
end