#
# A hash modifier that creates method readers from key names.
# NOTE: reader methods are created recursively.
# The method names are the same as the key names,
# except that the values are snake-cased, for example:
#   - QTime -> q_time
#   - debugQuery -> debug_query
#
class RSolr::Ext::HashMethodizer
  
  class << self
    
    def snake_case(v)
      v = v.to_s
      return v.downcase if v =~ /^[A-Z]+$/
      v.gsub(/([A-Z]+)(?=[A-Z][a-z]?)|\B[A-Z]/, '_\&') =~ /_*(.*)/
      return $+.downcase
    end
    
    def methodize!(h)
      h.keys.each do |k|
        meth = snake_case(k)
        val_key = case k
        when String
          "'#{k}'"
        when Symbol
          ":#{k}"
        else
          raise 'Supports only string/symbol keys!'
        end
        h.instance_eval <<-RUBY
        def #{meth}
          val = self[#{val_key}]
          if val.respond_to?(:each_pair)
            RSolr::Ext::HashMethodizer.methodize!(val)
          elsif val.is_a?(Array)
            val.each do |item|
              RSolr::Ext::HashMethodizer.methodize!(item) if item.respond_to?(:each_pair)
            end
          end
          val
        end
        RUBY
      end

    end
  
  end
  
end