module RSolrExt::Response::Luke

  include Base

  {
    :index=>:index,
    :directory=>:directory,
    :has_deletions=>:hasDeletions,
    :optimized=>:optimized,
    :current=>:current,
    :max_doc=>:maxDoc,
    :num_docs=>:numDocs,
    :version=>:version
  }.each_pair do |k,v|
    define_method(k){self[v]}
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
    mash = hash.to_mash
    mash.extend self
    mash
  end
  
end# end Luke