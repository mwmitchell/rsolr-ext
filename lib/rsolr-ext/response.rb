module RSolr::Ext::Response
  
  autoload :Facetable, 'rsolr-ext/response/facetable'
  autoload :Pageable, 'rsolr-ext/response/pageable'
  autoload :DocExt, 'rsolr-ext/response/doc_ext'
  
  class Base < Mash
    
    attr_reader :raw_response
    
    def initialize(raw_response)
      @raw_response = raw_response
      super(raw_response)
      RSolr::Ext::HashMethodizer.methodize!(self)
    end
    
    def ok?
      response_header.status == 0
    end
    
  end
  
  # 
  class Standard < Base
    
    include Facetable
    
    def initialize(*a)
      super
      activate_pagination!
    end
    
    def activate_pagination!
      response.docs.each{ |d| d.extend DocExt }
      d = response.docs
      d.extend Pageable
      d.start = response_header.params[:start].to_s.to_i
      d.per_page = response_header.params[:rows].to_s.to_i
      d.total = response.num_found
    end
    
  end
  
  class Dismax < Standard
    
  end
  
  # 
  class RSolr::Ext::Response::Luke < Base
    
    # Returns an array of fields from the index
    # An optional rule can be used for "grepping" field names:
    # field_list(/_facet$/)
    def field_list(rule=nil)
      fetch(:fields).select do |k,v|
        rule ? k =~ rule : true
      end.collect{|k,v|k}
    end

  end# end Luke
  
  # Update
  class Update < Base
    
  end
  
end