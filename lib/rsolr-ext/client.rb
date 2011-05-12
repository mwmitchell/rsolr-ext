module RSolr::Ext::Client

  # TWO modes of arguments:
  #
  # <request-handler-path>, <solr-params-hash>
  # OR
  # <solr-params-hash>
  #
  # The default request-handler-path is select
  # 
  # If a hash is used for solr params, all of the normal RSolr::Ext::Request
  # mappings are available (everything else gets passed to solr).
  # Returns a new RSolr::Ext::Response::Base object.
  def find *args
    path, params, opts = rsolr_request_arguments_for(*args)
    # send path, map params and send the rest of the args along
    response = self.send_and_receive path, opts.merge({ :params => RSolr::Ext::Request.map(params) })
    RSolr::Ext::Response::Base.new(response, path, params)
  end

  # A simple helper method to return an integer value for the count of
  # resulting rows for the specified query.
  def count *args
    path, params, opts = rsolr_request_arguments_for(*args)
    find(path, params.merge(:rows => 0), opts).total
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
    path = args.first.is_a?(String) ? args.shift : 'admin/luke'
    params = args.pop || {}
    params['numTerms'] ||= 0
    self.get(path, params).to_mash
  end
  
  # sends request to /admin/ping
  def ping *args
    path = args.first.is_a?(String) ? args.shift : 'admin/ping'
    params = args.pop || {:wt => :ruby}
    self.get(path, params).to_mash
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
  rescue Exception => exception
    raise_connection_exceptions ? raise(exception) : false
  end
  
  private

    # Helper method to return the parameters needed for requesting
    # from Solr.
    def rsolr_request_arguments_for *args
      [].tap do |arr|
        # remove the handler arg - the first, if it is a string OR set default
        arr << (args.first.is_a?(String) ? args.shift : 'select')
        # remove the params - the first, if it is a Hash OR set default
        arr << (args.first.kind_of?(Hash) ? args.shift : {})
        # everything that isn't params is opts
        arr << (args.first.kind_of?(Hash) ? args.shift : {})
      end
    end
end