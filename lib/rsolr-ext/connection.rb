module RSolr::Ext::Connection
  
  # TWO modes of arguments:
  #
  # <request-handler-path>, <solr-params-hash>
  # OR
  # <solr-params-hash>
  #
  # The default request-handler-path is /select
  # 
  # If a hash is used for solr params, all of the normal RSolr::Ext::Request
  # mappings are available (everything else gets passed to solr).
  # Returns a new RSolr::Ext::Response::Base object.
  def find *args
    # remove the handler arg - the first, if it is a string OR set default
    path = args.first.is_a?(String) ? args.shift : '/select'
    # remove the params - the first, if it is a Hash OR set default
    params = args.first.kind_of?(Hash) ? args.shift : {}
    # send path, map params and send the rest of the args along
    response = self.request path, RSolr::Ext::Request.map(params), *args
    RSolr::Ext::Response::Base.new(response)
  end
  
  # TWO modes of arguments:
  #
  # <request-handler-path>, <solr-params-hash>
  # OR
  # <solr-params-hash>
  #
  # The default request-handler-path is /admin/luke
  # The default params are numTerms=0
  #
  # Returns a new Mash object.
  def luke *args
    path = args.first.is_a?(String) ? args.shift : '/admin/luke'
    params = args.pop || {}
    params['numTerms'] ||= 0
    self.request(path, params).to_mash
  end
  
end