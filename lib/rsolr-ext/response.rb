module RSolr::Ext::Response
  
  autoload :Facetable, 'rsolr-ext/response/facetable'
  autoload :Pageable, 'rsolr-ext/response/pageable'
  autoload :DocExt, 'rsolr-ext/response/doc_ext'
  
  class Base < Mash
    
    def header
      self[:responseHeader]
    end
    
    def ok?
      header[:status] == 0
    end
    
  end
  
  # 
  class Standard < Base
    
    include Facetable
    
    def initialize(*a)
      super(*a)
      activate_pagination!
    end
    
    def response
      self[:response]
    end
    
    def docs
      response[:docs]
    end
    
    private
    
    def activate_pagination!
      d = self[:response][:docs]
      d.each{|dhash| dhash.extend DocExt }
      d.extend Pageable
      d.start = self[:responseHeader][:params][:start].to_s.to_i
      d.per_page = self[:responseHeader][:params][:rows].to_s.to_i
      d.total = self[:response][:numFound]
    end
    
  end
  
  class Dismax < Standard
    
  end
  
  # 
  class Luke < Base
    
    # Returns an array of fields from the index
    # An optional rule can be used for "grepping" field names:
    # field_list(/_facet$/)
    def field_list(rule=nil)
      self[:fields].select do |k,v|
        rule ? k =~ rule : true
      end.collect{|k,v|k}
    end

  end# end Luke
  
  # Update
  class Update < Base
    
  end
  
end