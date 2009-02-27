module RSolr
  
  module Params
    
    module CommonHelpers
      
      def prep_value(value, quote)
        quote ? %("#{value}") : value
      end
    
      def build_query(value, quote)
        case value
        when Array
          value.collect do |item|
            build_query item, quote
          end.flatten
        when String,Symbol
          [prep_value(value.to_s, quote)]
        when Hash
          value.collect do |(k,v)|
            "#{k}:#{build_query(v, quote).join(' ')}"
          end.flatten
        else
          [prep_value(value.to_s, quote)]
        end
      end
      
    end
    
    class Standard
      
      FIELD_LIST = [:per_page, :page, :queries, :phrase_queries, :filters, :phrase_filters, :facets]
    
      include CommonHelpers
    
      def map(input)
        output={}
        FIELD_LIST.each do |field|
          send("map_#{field}", output, input[field]) unless input[field].to_s.empty?
        end
        output
      end
    
      def map_per_page(output,value)
        value = value.to_s.to_i
        output[:rows] = value < 0 ? 0 : value
      end
    
      def map_page(output,value)
        value = value.to_s.to_i
        page = value > 0 ? value : 1
        output[:start] = ((page - 1) * (output[:rows] || 0))
      end
    
      def map_facets(output,value)
        
      end
    
      def map_queries(output,value)
        output[:q] = build_query(value, false).join(' ')
      end
      
      # add the phrases on to the previously created q param
      # weed out any empty values, then join on a space
      def map_phrase_queries(output,value)
        phrases = build_query(value, true)
        output[:q] = [output[:q], phrases].reject{|s|s.to_s.empty?}.join(' ')
      end
    
      def map_filters(output,value)
        output[:fq] = build_query(value, false).join(' ')
      end
    
      def map_phrase_filters(output,value)
        filters = build_query(value, true)
        output[:fq] = [output[:fq], filters].reject{|s|s.to_s.empty?}.join(' ')
      end
  
    end
  
    def self.standard(input)
      Standard.new.map(input)
    end
    
    def self.dismax(input)
      Dismax.new.map(input)
    end
  
  end
  
end