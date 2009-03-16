module RSolr::Ext::Request
  
  module Mapable
    
    def map(input)
      result = input.dup
      self.class::MAPPED_PARAMS.each do |meth|
        input_value = result.delete(meth)
        next if input_value.to_s.empty?
        send("map_#{meth}", input_value, result)
      end
      result
    end
    
    def append_to_param(existing_value, new_value)
      values = [existing_value, new_value]
      values.delete_if{|v|v.nil?}
      values.join(' ')
    end
    
  end
  
  module Queryable
    
    def quote(value)
      %("#{value}")
    end
    
    def build_range(r)
      "[#{r.min} TO #{r.max}]"
    end
    
    def build_query(value, quote_string=false)
      case value
      when String,Symbol
        return quote_string ? quote(value.to_s) : value.to_s
      when Array
        value.collect do |v|
          build_query(v, quote_string)
        end.flatten
      when Hash
        return value.collect do |(k,v)|
          if v.is_a?(Range)
            "#{k}:#{build_range(v)}"
          else
            "#{k}:#{build_query(v, quote_string)}"
          end
        end.flatten
      end
    end
  end
  
  autoload :Standard, 'rsolr-ext/request/standard.rb'
  autoload :Dismax, 'rsolr-ext/request/dismax.rb'
  
end