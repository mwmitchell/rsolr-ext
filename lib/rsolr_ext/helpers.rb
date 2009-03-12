# basic helpers for formatting strings/array/hashes
module RSolrExt::Helpers
    
  # returns a quoted or non-quoted string
  # "value" should be a string
  # "quote" should be true/false
  def prep_value(value, quote)
    quote ? %("#{value}") : value
  end
  
  # value can be a string, array, hash or symbol
  # symbols are treated as strings
  # arrays are recursed through #build_query
  # keys for hashes are fields for fielded queries, the values are recused through #build_query
  # strings/symbols are sent to #prep_value for possible quoting
  #
  # opts can have:
  #   :quote=>bool - default false
  #   :join=>string - default ' '
  def build_query(value, opts={})
    opts[:join]||=' '
    opts[:quote]||=false
    result = (
      case value
      when Array
        value.collect do |item|
          build_query item, opts
        end.flatten
      when String,Symbol
        [prep_value(value.to_s, opts[:quote])]
      when Hash
        value.collect do |(k,v)|
          "#{k}:#{build_query(v, opts)}"
        end.flatten
      else
        [prep_value(value.to_s, opts[:quote])]
      end
    )
    opts[:join] ? result.join(opts[:join]) : result
  end
  
end