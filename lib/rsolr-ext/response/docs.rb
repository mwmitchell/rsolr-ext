module RSolr::Ext::Response::Docs
  
  def self.extended(base)
    d = base['response']['docs']
    # TODO: could we do this lazily (Enumerable etc.)
    d.each{|doc| doc.extend RSolr::Ext::Doc }
    d.extend Pageable
    d.per_page = [base.rows, 1].max
    d.start = base.start
    d.total = base.total
  end
  
  module Pageable
    
    attr_accessor :start, :per_page, :total
    
    # Returns the current page calculated from 'rows' and 'start'
    # WillPaginate hook
    def current_page
      return 1 if start < 1
      per_page_normalized = per_page < 1 ? 1 : per_page
      @current_page ||= (start / per_page_normalized).ceil + 1
    end
    
    def limit_value
      per_page
    end
    
    # Calcuates the total pages from 'numFound' and 'rows'
    # WillPaginate hook
    def total_pages
      @total_pages ||= per_page > 0 ? (total / per_page.to_f).ceil : 1
    end
    
    # returns the previous page number or 1
    # WillPaginate hook
    def previous_page
      @previous_page ||= (current_page > 1) ? current_page - 1 : 1
    end
    
    # returns the next page number or the last
    # WillPaginate hook
    def next_page
      @next_page ||= (current_page == total_pages) ? total_pages : current_page+1
    end
    
    def has_next?
      current_page < total_pages
    end
    
    def has_previous?
      current_page > 1
    end
    
  end
  
  def docs
    @docs ||= begin
      response['docs']
    end
  end
  
end
