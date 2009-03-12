# for update responses
module RSolrExt::Response::Update
  
  include Base
  
  # converts to mash, then extends
  def self.create(hash)
    mash = hash.to_mash
    mash.extend self
    mash
  end
  
end