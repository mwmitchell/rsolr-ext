module RSolr::Ext::Request
  
  module Params
    
    def map input
      output = {}
      if input[:per_page]
        output[:rows] = input.delete(:per_page).to_i
      end
      
      if page = input.delete(:page)
        raise ':per_page must be set when using :page' unless output[:rows]
        page = page.to_s.to_i-1
        page = page < 1 ? 0 : page
        output[:start] = page * output[:rows]
      end
      
      if queries = input.delete(:queries)
        output[:q] = append_to_param output[:q], build_query(queries, false)
      end
      if phrases = input.delete(:phrases)
        output[:q] = append_to_param output[:q], build_query(phrases, true)
      end
      if filters = input.delete(:filters)
        output[:fq] = append_to_param output[:fq], build_query(filters), false
      end
      if phrase_filters = input.delete(:phrase_filters)
        output[:fq] = append_to_param output[:fq], build_query(phrase_filters, true), false
      end
      if facets = input.delete(:facets)
        output[:facet] = true
        output['facet.field'] = append_to_param output['facet.field'], build_query(facets.values), false
      end
      output.merge input
    end
    
  end
  
  module QueryHelpers
    
    # Wraps a string around double quotes
    def quote(value)
      %("#{value}")
    end

    # builds a solr range query from a Range object
    def build_range(r)
      "[#{r.min} TO #{r.max}]"
    end

    # builds a solr query fragment
    # if "quote_string" is true, the values will be quoted.
    # if "value" is a string/symbol, the #to_s method is called
    # if the "value" is an array, each item in the array is 
    # send to build_query (recursive)
    # if the "value" is a Hash, a fielded query is built
    # where the keys are used as the field names and
    # the values are either processed as a Range or
    # passed back into build_query (recursive)
    def build_query(value, quote_string=false)
      case value
      when String,Symbol
        quote_string ? quote(value.to_s) : value.to_s
      when Array
        value.collect do |v|
          build_query(v, quote_string)
        end.flatten
      when Hash
        return value.collect do |(k,v)|
          if v.is_a?(Range)
            "#{k}:#{build_range(v)}"
          # If the value is an array, we want the same param, multiple times (not a query join)
          elsif v.is_a?(Array)
            v.collect do |vv|
              "#{k}:#{build_query(vv, quote_string)}"
            end
          else
            "#{k}:#{build_query(v, quote_string)}"
          end
        end.flatten
      end
    end

    # creates an array where the "existing_value" param is first
    # and the "new_value" is the last.
    # All empty/nil items are removed.
    # the return result is either the result of the
    # array being joined on a space, or the array itself.
    # "auto_join" should be true or false.
    def append_to_param(existing_value, new_value, auto_join=true)
      values = [existing_value, new_value]
      values.delete_if{|v|v.nil?}
      auto_join ? values.join(' ') : values.flatten
    end
    
  end
  
  extend QueryHelpers
  extend Params
  
end