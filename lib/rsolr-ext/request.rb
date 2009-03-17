module RSolr::Ext::Request
  
  # A module that provides method mapping capabilities.
  # The basic idea is to pass in a hash to the #map method,
  # the map method then goes through a list of keys to
  # be processed. Each key name can match a key in the input hash.
  # If there is a match, a method by the name of "map_#{key}" is
  # called with the following args: input[key], output_hash
  # The method is responsible for processing the value.
  # The return value from the method does nothing.
  #
  # For example: if the mapped params list has a name, :query,
  # there should be a method like: map_query(input_value, output_hash)
  module Mapable
    
    # accepts an input hash.
    # prepares a return hash by copying the input.
    # runs through all of the keys in MAPPED_PARAMS.
    # calls any mapper methods that match the current key in MAPPED_PARAMS.
    # The mapped keys from the input hash are deleted.
    # returns a new hash.
    def map(input)
      result = input.dup
      self.class::MAPPED_PARAMS.each do |meth|
        input_value = result.delete(meth)
        next if input_value.to_s.empty?
        send("map_#{meth}", input_value, result)
      end
      result
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
      auto_join ? values.join(' ') : values
    end
    
  end
  
  # a module to help the creation of solr queries.
  module Queryable
    
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