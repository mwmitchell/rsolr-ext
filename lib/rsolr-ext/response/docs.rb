require 'will_paginate/collection'

module RSolr::Ext::Response::Docs

  module Pageable
    def has_next?
      current_page < total_pages
    end

    def has_previous?
      current_page > 1
    end
  end
  
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
        pager.extend Pageable
      end
    end
  end
  
end
