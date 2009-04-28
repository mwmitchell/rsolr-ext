# add this directory to the load path if it hasn't already been added

lambda { |base|
  $: << base unless $:.include?(base) || $:.include?(File.expand_path(base))
}.call(File.dirname(__FILE__))

unless defined?(Mash)
  require 'mash'
end

unless Hash.respond_to?(:to_mash)
  class Hash
    def to_mash
      Mash.new(self)
    end
  end
end

module RSolr
  
  module Ext
    
    VERSION = '0.6.0'
    
    autoload :Request, 'rsolr-ext/request.rb'
    autoload :Response, 'rsolr-ext/response.rb'
    autoload :Mapable, 'rsolr-ext/mapable.rb'
    autoload :Access, 'rsolr-ext/access.rb'
    
  end
  
end