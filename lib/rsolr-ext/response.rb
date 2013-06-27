module RSolr::Ext::Response

  autoload :Docs, 'rsolr-ext/response/docs'
  autoload :Facets, 'rsolr-ext/response/facets'
  autoload :Spelling, 'rsolr-ext/response/spelling'

  class Base < Mash

    attr :original_hash
    attr_reader :request_path, :request_params

    def initialize hash, handler, request_params
      super hash
      @original_hash = hash
      @request_path, @request_params = request_path, request_params
      extend Response
      extend Docs
      extend Facets
      extend Spelling
    end

    def header
      self['responseHeader']
    end

    def rows
      # With Solr 4 and RSolr 1.0.9 this param is an array instead
      # of an integer value. If the param is an array then the first value
      # will be returned, otherwise it will be done like before.
      rows = params[:rows]
      return rows.first.to_i if rows.kind_of?(Array)
      rows.to_i
    end

    def params
      (header and header['params']) ? header['params'] : request_params
    end

    def ok?
      (header and header['status']) ? header['status'] == 0 : nil
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
      response[:numFound].to_s.to_i
    end

    def start
      response[:start].to_s.to_i
    end

  end

end