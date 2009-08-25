module RSolr::Ext::Doc
  
  # for easy access to the solr id (route helpers etc..)
  def id
    self['id']
  end
  
  # Helper method to check if value/multi-values exist for a given key.
  # The value can be a string, or a RegExp
  # Multiple "values" can be given; only one needs to match.
  # 
  # Example:
  # doc.has?(:location_facet)
  # doc.has?(:location_facet, 'Clemons')
  # doc.has?(:id, 'h009', /^u/i)
  def has?(k, *values)
    return if self[k].nil?
    return true if self.key?(k) and values.empty?
    target = self[k]
    if target.is_a?(Array)
      values.each do |val|
        return target.any?{|tv| val.is_a?(Regexp) ? (tv =~ val) : (tv==val)}
      end
    else
      return values.any? {|val| val.is_a?(Regexp) ? (target =~ val) : (target == val)}
    end
  end

  # helper
  # key is the name of the field
  # opts is a hash with the following valid keys:
  #  - :sep - a string used for joining multivalued field values
  #  - :default - a value to return when the key doesn't exist
  # if :sep is nil and the field is a multivalued field, the array is returned
  def get key, opts={:sep=>', ', :default=>nil}
    if self.key? key
      val = self[key]
      (val.is_a?(Array) and opts[:sep]) ? val.join(opts[:sep]) : val
    else
      opts[:default]
    end
  end

end