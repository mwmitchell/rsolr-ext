module RSolr::Ext::Response::Docs
  
  def self.extended(base)
    d = base['response']['docs']
    d.each{|doc| doc.extend RSolr::Ext::Doc }
  end
  
  def docs
    response['docs']
  end
  
end