# utility for querying building
# RSolrExt::Params.escape('a string...')
# q = RSolrExt::Params.create_fielded_queries(:name=>'a string...', :cat=>[:one, :two])
# q == ["a string...", "cat:one", "cat:two"]
class RSolrExt::Params
  
  def self.escape(value, quote=false)
    quote ? %("#{value}") : value
  end
  
  def self.create_fielded_queries(params, quote=nil)
    params.collect do |k,v|
    	v.is_a?(Array) ? v.collect{|vv|%(#{k}:#{escape(vv, quote)})} : "#{k}:#{escape(v, quote)}"
    end.flatten
  end

  def self.calculate_start(page, rows)
    page = page.to_s.to_i-1
    page = page < 1 ? 0 : page
    page * rows.to_i
  end
  
end