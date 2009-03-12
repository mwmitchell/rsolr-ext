#
# my_solr_hash.extend RSolrExt::Response::Base
# my_solr_hash.header
# my_solr_hash.ok?
#
module RSolrExt::Response::Base
  
  # create the method accessors
  {
    :header=>:responseHeader,
    :params=>:params,
    :status=>:status,
    :query_time=>:QTime
  }.each_pair do |k,v|
    define_method(k){self[v]}
  end

  def ok?
    self.status == 0
  end
  
  # converts to mash, then extends
  def self.create(hash)
    mash = hash.to_mash
    mash.extend self
    mash
  end
  
end # end Base