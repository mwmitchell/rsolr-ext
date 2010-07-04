module RSolr::Ext::Client
  
  # TWO modes of arguments:
  #
  # <request-handler-path>, <solr-params-hash>
  # OR
  # <rsolr-options-hash>
  #
  # The default request-handler-path is select
  # 
  # If a hash is used for solr params, all of the normal RSolr::Ext::Request
  # mappings are available (everything else gets passed to solr).
  # Returns a new RSolr::Ext::Response::Base object.
  def find *args
    # remove the handler arg - the first, if it is a string OR set default
    path = args.first.is_a?(String) ? args.shift : 'select'
    # remove the params -- always after path
    opts = args.first.kind_of?(Hash) ? args.shift : {}
    # determine the param source (POST/:data or GET/:params)
    if opts[:method] == :post
      params = opts[:data] ||= {}
    else
      params = opts[:params] ||= {}
    end
    params.merge! RSolr::Ext::Request.map(params)
    if params[:page] or params[:per_page]
      response = self.paginate params.delete(:page), params.delete(:per_page), path, opts
    else
      response = self.send_request path, opts
    end
    RSolr::Ext::Response::Base.new(response, path, opts)
  end
  
  # TWO modes of arguments:
  #
  # <request-handler-path>, <solr-params-hash>
  # OR
  # <solr-params-hash>
  #
  # The default request-handler-path is admin/luke
  # The default params are numTerms=0
  #
  # Returns a new Mash object.
  def luke opts = {}
    opts[:params] ||= {}
    opts[:params][:numTerms] ||= 0
    self.send_request('admin/luke', opts).to_mash
  end
  
  # sends request to /admin/ping
  def ping opts = {}
    self.send_request('admin/ping', opts).to_mash
  end
  
  # Ping the server and make sure it is alright
  #   solr.ping?
  #
  # It returns true if the server pings and the status is OK
  # It returns false otherwise -- which probably cannot happen
  # Or raises an exception if there is a failure to connect or
  # the ping service is not activated in the solr server
  #
  # The default configuration point of the PingRequestHandler
  # in the solr server of '/admin/ping' is assumed.
  #
  def ping?
    ping['status'] == 'OK'
  end
  
end