module RSolr
  
  module Ext
    
    # basic helpers for formatting strings/array/hashes
    module HelperMethods
      
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
      
      # start_for(2, 10)
      # calculates the :start value for pagination etc..
      def start_for(current_page, per_page)
        page = current_page.to_s.to_i
        page = page > 0 ? page : 1
        ((page - 1) * (per_page || 0))
      end
      
    end # end HelperMethods
    
    module ToSolrable
      
      def to_solr
        output = self.dup#Marshal.load(Marshal.dump(self))
        mapped_params.each do |param_name|
          value = output.delete(param_name)
          send("map_#{param_name}", output, value) if value
        end
        output
      end
      
    end
    
    module Request
      
      module Select
        
        class Standard < Hash
          
          include HelperMethods
          include ToSolrable
          
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
        
      end
      
    end
    
  end # end Ext
  
end # end RSolr