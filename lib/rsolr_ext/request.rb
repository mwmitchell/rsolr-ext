module RSolrExt::Request
  
  module Select
    
    class Standard < Hash
      
      include RSolrExt::Helpers
      include RSolrExt::ToSolrable
      
      def mapped_params
        [:per_page, :page, :phrases, :filters, :phrase_filters, :facets]
      end
      
      def map_per_page(params,value)
        value = value.to_s.to_i
        params[:rows] = value < 0 ? 0 : value
      end
      
      def map_page(params,value)
        value = value.to_s.to_i
        value = value > 0 ? value : 1
        params[:start] = ((value - 1) * (params[:rows] || 0))
      end
      
      def map_phrases(params,value)
        values = [params[:q], build_query(value, :quote=>true)]
        # remove blank items
        values.reject!{|v|v.to_s.empty?}
        # join all items on a space
        params[:q] = values.join(' ') unless values.empty?
      end
      
      def map_filters(params,value)
        values = [params[:fq], build_query(value, :quote=>false)]
        # remove blank items
        values.reject!{|v|v.to_s.empty?}
        # join all items on a space
        params[:fq] = values.join(' ') unless values.empty?
      end
      
      def map_phrase_filters(params,value)
        values = [params[:fq], build_query(value, :quote=>true)]
        # remove blank items
        values.reject!{|v|v.to_s.empty?}
        # join all items on a space
        params[:fq] = values.join(' ') unless values.empty?
      end
      
      def map_facets(params,value)
        next if value.to_s.empty?
        params[:facet] = true
        params['facet.field'] = []
        if value[:queries]
          # convert to an array if needed
          value[:queries] = [value[:queries]] unless value[:queries].is_a?(Array)
          params['facet.query'] = value[:queries].map{|q|build_query(q)}
        end
        common_sub_fields = [:sort, :limit, :missing, :mincount, :prefix, :offset, :method, 'enum.cache.minDf']
        (common_sub_fields).each do |subfield|
          next unless value[subfield]
          params["facet.#{subfield}"] = value[subfield]
        end
        if value[:fields]
          value[:fields].each do |f|
            if f.kind_of? Hash
              key = f.keys[0]
              value = f[key]
              params[:facet.field] << key
              common_sub_fields.each do |subfield|
                next unless value[subfield]
                params["f.#{key}.facet.#{subfield}"] = value[subfield]
              end
            else
              params['facet.field'] << f
            end
          end
        end
      end
    end
    
  end # end Select
  
  module Update
    
  end
  
end # end Request