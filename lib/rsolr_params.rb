module RSolr; end

class RSolr::Params
  
  module BuilderHelpers
    
    # takes an input and returns a formatted value
    def format_query(input, quote=false)
      case input
      when Array
        format_array_query(input, quote)
      when Hash
        format_hash_query(input, quote)
      else
        prep_value(input, quote)
      end
    end
    
    def format_array_query(input, quote)
      input.collect do |v|
        v.is_a?(Hash) ? format_hash_query(v, quote) : prep_value(v, quote)
      end
    end
    
    # groups values to a single field: title:(value1 value2) instead of title:value1 title:value2
    # a value can be a range or a string
    def format_hash_query(input, quote=false)
      q = []
      input.each_pair do |field,value|
        next if value.to_s.empty? # skip blank values!
        # create the field plus the delimiter if the field is not blank
        value = [value] unless value.is_a?(Array)
        fielded_queries = value.collect do |vv|
          vv.is_a?(Range) ? "[#{vv.min} TO #{vv.max}]" : prep_value(vv, quote)
        end
        field = field.to_s.empty? ? '' : "#{field}:"
        fielded_queries.each do |fq|
          q << "#{field}(#{fq})"
        end
      end
      q
    end

    def prep_value(val, quote=false)
      quote ? %(\"#{val}\") : val.to_s
    end
  
  end
  
  class StandardMapper
    
    include BuilderHelpers
    
    def map(params)
      if params[:per_page]
        per_page = params.delete(:per_page).to_s.to_i
        params[:rows] = per_page < 0 ? 0 : per_page
      end
      
      if params[:page]
        page = params.delete(:page).to_s.to_i
        page = page > 0 ? page : 1
        params[:start] = ((page - 1) * (params[:rows] || 0))
      end
      
      if params[:queries]
        queries = params.delete :queries
        params[:q] = format_query(queries)
      end
      
      if params[:phrase_queries]
        phrase_queries = params.delete :phrase_queries
        phrase_queries = [params[:q], format_query(phrase_queries, true)]
        # remove blank items
        phrase_queries.reject!{|v|v.to_s.empty?}
        # join all items on a space
        params[:q] = phrase_queries.join(' ')
      end
      
      if params[:filters]
        filters = params.delete :filters
        params[:fq] = format_query(filters)
      end
      
      if params[:phrase_filters]
        phrase_filters = params.delete :phrase_filters
        # use the previously set fq queries and generate the new phrased based ones
        phrase_filters = [params[:fq], format_query(phrase_filters, true)]
        # flatten (need to do this because the previous fq could have been an array)
        phrase_filters = phrase_filters.flatten
        # remove blank items
        phrase_filters.reject!{|v|v.to_s.empty?} # don't join -- instead create multiple fq params
        # don't join... fq needs to be an array so multiple fq params are sent to solr
        params[:fq] = phrase_filters
      end
      
      if params[:facets]
        facets = params.delete :facets
        params[:facet] = true
        params['facet.field'] = []
        if facets[:queries]
          # convert to an array if needed
          facets[:queries] = [facets[:queries]] unless facets[:queries].is_a?(Array)
          params['facet.query'] = facets[:queries].map{|q|format_query(q)}
        end
        common_sub_fields = [:sort, :limit, :missing, :mincount, :prefix, :offset, :method, 'enum.cache.minDf']
        (common_sub_fields).each do |subfield|
          next unless facets[subfield]
          params["facet.#{subfield}"] = facets[subfield]
        end
        if facets[:fields]
          facets[:fields].each do |f|
            if f.kind_of? Hash
              key = f.keys[0]
              value = f[key]
              params['facet.field'] << key
              common_sub_fields.each do |subfield|
                next unless value[subfield]
                params["f.#{key}.facet.#{subfield}"] = facets[subfield]
              end
            else
              params['facet.field'] << f
            end
          end
        end
      end
      params
    end
    
  end
  
  class DismaxMapper < StandardMapper
    
    def map(params)
      params = super(params)
      if params[:alternate_query]
        params['q.alt'] = format_query(params.delete(:alternate_query)).join(' ')
      end
      
      if params[:query_fields]
        params[:qf] = create_boost_query(params.delete(:query_fields))
      end
      
      if params[:phrase_fields]
        params[:pf] = create_boost_query(params.delete(:phrase_fields))
      end
      
      if params[:boost_query]
        params[:bq] = format_query(params.delete(:boost_query)).join(' ')
      end
      params
    end
    
    
    protected
    
    def create_boost_query(input)
      case input
      when Hash
        qf = []
        input.each_pair do |k,v|
          qf << (v.to_s.empty? ? k : "#{k}^#{v}")
        end
        qf.join(' ')
      when Array
        input.join(' ')
      when String
        input
      end
    end
    
  end
  
  def self.standard(params)
    StandardMapper.new.map(params)
  end
  
  def self.dismax(params)
    DismaxMapper.new.map(params)
  end
  
end