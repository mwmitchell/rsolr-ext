# for update responses
module RSolr::Ext::Response::Update
  
  include Base
  
  # converts to mash, then extends
  def self.create(hash)
    mash = hash.is_a?(Mash) ? hash : hash.to_mash
    mash.extend self
    mash
  end
  
end