module RSolr::Ext::Response
  
  autoload :Docs, 'rsolr-ext/response/docs'
  autoload :Facets, 'rsolr-ext/response/facets'
  autoload :Spelling, 'rsolr-ext/response/spelling'
  
  class Base < Mash
    
    attr :original_hash
    
    def initialize hash
      super hash
      @original_hash = hash
      extend Response# if self['response']
      extend Docs# if self['response'] and self['response']['docs']
      extend Facets# if self['facet_counts']
      extend Spelling# if self['spellcheck']
    end
    
    def header
      self['responseHeader']
    end
    
    def params
      header['params']
    end
    
    def ok?
      header['status'] == 0
    end
    
    def method_missing *args, &blk
      self.original_hash.send *args, &blk
    end
    
  end
  
  module Response
    
    def response
      self[:response]
    end
    
    # short cut to response['numFound']
    def total
      response[:numFound]
    end
    
  end
  
end