module RSolr::Ext::Response::Luke
  
  include Base
  
  def index
    self[:index]
  end
  
  def directory
    index[:directory]
  end
  
  def has_deletions
    index[:hasDeletions]
  end
  
  def current
    index[:current]
  end
  
  def max_doc
    index[:max_doc]
  end
  
  def num_docs
    index[:numDocs]
  end
  
  def version
    index[:version]
  end
  
  alias :has_deletions? :has_deletions
  alias :optimized? :optimized
  alias :current? :current

  # Returns an array of fields from the index
  # An optional rule can be used for "grepping" field names:
  # field_list(/_facet$/)
  def field_list(rule=nil)
    self[:fields].select do |k,v|
      rule ? k =~ rule : true
    end.collect{|k,v|k}
  end
  
  # converts to mash, then extends
  def self.create(hash)
    mash = hash.is_a?(Mash) ? hash : hash.to_mash
    mash.extend self
    mash
  end
  
end# end Luke