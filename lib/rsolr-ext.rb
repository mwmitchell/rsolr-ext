# add this directory to the load path if it hasn't already been added
lambda {|base|
  $: << base unless $:.include?(base) || $:.include?(File.expand_path(base))
}.call(File.dirname(__FILE__))

unless defined?(Mash)
  require 'mash'
end

unless Hash.respond_to?(:to_mash)
  require 'core_ext'
end

module RSolr
  
  module Ext
    
    VERSION = '0.5.9'
    
    autoload :Request, 'rsolr-ext/request.rb'
    autoload :Response, 'rsolr-ext/response.rb'
    autoload :Mapable, 'rsolr-ext/mapable.rb'
    
  end
  
end