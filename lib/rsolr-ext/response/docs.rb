require 'will_paginate/collection'

module RSolr::Ext::Response::Docs
  
  def self.extended(base)
    d = base['response']['docs']
    d.each{|doc| doc.extend RSolr::Ext::Doc }
  end
  
  def docs
    @docs ||= begin
      per_page = [self.rows, 1].max
      page = (self.start / per_page).ceil + 1

      WillPaginate::Collection.create(page, per_page, self.total) do |pager|
        pager.replace(response['docs'])
      end
    end
  end
  
end
