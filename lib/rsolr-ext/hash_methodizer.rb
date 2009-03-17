class RSolr::Ext::HashMethodizer
  
  class << self
    
    def snake_case(v)
      return v.downcase if v =~ /^[A-Z]+$/
      v.gsub(/([A-Z]+)(?=[A-Z][a-z]?)|\B[A-Z]/, '_\&') =~ /_*(.*)/
      return $+.downcase
    end
    
    def methodize!(h)
      h.keys.each do |k|
        meth = snake_case(k)
        h.instance_variable_set("@#{k}", h[k])
        h.instance_eval <<-RUBY
        def #{meth}
          val = @#{k}
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