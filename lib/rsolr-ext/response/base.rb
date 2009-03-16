#
# my_solr_hash.extend RSolrExt::Response::Base
# my_solr_hash.header
# my_solr_hash.ok?
#
module RSolr::Ext::Response::Base
  
  def header
    self[:responseHeader]
  end
  
  def params
    header[:params]
  end
  
  def status
    header[:status].to_i
  end
  
  def query_time
    header[:QTime]
  end
  
  def ok?
    self.status == 0
  end
  
  # converts to mash, then extends
  def self.create(hash)
    mash = hash.is_a?(Mash) ? hash : hash.to_mash
    mash.extend self
    mash
  end
  
end # end Base