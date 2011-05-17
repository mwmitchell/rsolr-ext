module RSolr::Ext::Response::Docs
  
  # NOTE: This might move/change in the next major release of RSolr::Ext
  module WillPaginateExt
    class MissingLibError < RuntimeError
      def to_s; "WillPaginate is required" end
    end
    def will_paginate
      WillPaginate::Collection.create(self.current_page, self.per_page, self.total) do |pager|
        pager.replace(self)
      end
    rescue NameError
      raise MissingLibError.new
    end
  end
  
  def self.extended(base)
    d = base['response']['docs']
    # TODO: could we do this lazily (Enumerable etc.)
    d.each{|doc| doc.extend RSolr::Ext::Doc }
    d.extend Pageable
    d.per_page = [base.rows, 1].max
    d.start = base.start
    d.total = base.total
    d.extend WillPaginateExt
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
      warn "DEPRECATION WARNING: The custom pagination codebase in RSolr::Ext will no longer be supported. Use response.docs.will_paginate instead."
      response['docs']
    end
  end
  
end