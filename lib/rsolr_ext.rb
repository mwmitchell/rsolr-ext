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

module RSolrExt
  
  VERSION = '0.1.0'
  
  autoload :Params, 'rsolr_ext/params'
  autoload :Response, 'rsolr_ext/response'
  
end # end RSolrExt