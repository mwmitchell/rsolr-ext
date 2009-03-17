module RSolr::Ext::Response::Pageable
  
  attr_accessor :start, :per_page, :total
  
  # Returns the current page calculated from 'rows' and 'start'
  # WillPaginate hook
  def current_page
    return 1 if start < 1
    @current_page ||= (start / per_page).ceil + 1
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
    @next_page ||= (current_page < total_pages) ? current_page + 1 : total_pages
  end
  
end