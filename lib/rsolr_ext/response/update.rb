# for update responses
module RSolrExt::Response::Update
  
  include Base
  
  def self.create(hash)
    mash = hash.to_mash
    mash.extend self
    mash
  end
  
end