module RSolrExt::Response::Select
  
  # module for adding helper methods to each solr response[:docs] object
  module DocExt

    # Helper method to check if value/multi-values exist for a given key.
    # The value can be a string, or a RegExp
    # Example:
    # doc.has?(:location_facet)
    # doc.has?(:location_facet, 'Clemons')
    # doc.has?(:id, 'h009', /^u/i)
    def has?(k, *values)
      return if self[k].nil?
      return true if self.key?(k) and values.empty?
      target = self[k]
      if target.is_a?(Array)
        values.each do |val|
          return target.any?{|tv| val.is_a?(Regexp) ? (tv =~ val) : (tv==val)}
        end
      else
        return values.any? {|val| val.is_a?(Regexp) ? (target =~ val) : (target == val)}
      end
    end

    # helper
    # key is the name of the field
    # opts is a hash with the following valid keys:
    #  - :sep - a string used for joining multivalued field values
    #  - :default - a value to return when the key doesn't exist
    # if :sep is nil and the field is a multivalued field, the array is returned
    def get(key, opts={:sep=>', ', :default=>nil})
      if self.key? key
        val = self[key]
        (val.is_a?(Array) and opts[:sep]) ? val.join(opts[:sep]) : val
      else
        opts[:default]
      end
    end

  end

  module Facets
    
    # represents a facet value; which is a field value and its hit count
    class FacetValue
      attr_reader :value,:hits
      def initialize(value,hits)
        @value,@hits=value,hits
      end
    end
    
    # represents a facet; which is a field and its values
    class Facet
      attr_reader :field
      attr_accessor :values
      def initialize(field)
        @field=field
        @values=[]
      end
    end

    # @response.facets.each do |facet|
    #   facet.field
    # end
    # "caches" the result in the @facets instance var
    def facets
      # memoize!
      @facets ||= (
        facet_fields.inject([]) do |acc,(facet_field_name,values_and_hits_list)|
          acc << facet = Facet.new(facet_field_name)
          # the values_and_hits_list is an array where a value is immediately followed by it's hit count
          # so we shift off an item (the value)
          while value = values_and_hits_list.shift
            # and then shift off the next to get the hit value
            facet.values << FacetValue.new(value, values_and_hits_list.shift)
            # repeat until there are no more pairs in the values_and_hits_list array
          end
          acc
        end
      )
    end

    # pass in a facet field name and get back a Facet instance
    def facet_by_field_name(name)
      @facets_by_field_name ||= {}
      @facets_by_field_name[name] ||= (
        facets.detect{|facet|facet.field.to_s == name.to_s}
      )
    end
    
    def facet_counts
      @facet_counts ||= self[:facet_counts] || {}
    end

    # Returns the hash of all the facet_fields (ie: {'instock_b' => ['true', 123, 'false', 20]}
    def facet_fields
      @facet_fields ||= facet_counts[:facet_fields] || {}
    end

    # Returns all of the facet queries
    def facet_queries
      @facet_queries ||= facet_counts[:facet_queries] || {}
    end
    
  end # end Facets
  
  #
  #
  #
  class Paginator
    
    attr_reader :start, :per_page, :total
    
    def initialize(start, per_page, total)
      @start = start.to_s.to_i
      @per_page = per_page.to_s.to_i
      @total = total.to_s.to_i
    end
    
    # Returns the current page calculated from 'rows' and 'start'
    # WillPaginate hook
    def current_page
      return 1 if start < 1
      @current_page ||= (start / per_page).ceil + 1
    end

    # Calcuates the total pages from 'numFound' and 'rows'
    # WillPaginate hook
    def total_pages
      @total_pages ||= per_page > 0 ? (total / per_page.to_f).ceil : 1
    end

    # returns the previous page number or 1
    # WillPaginate hook
    def previous_page
      @previous_page ||= (current_page > 1) ? current_page - 1 : 1
    end
    
    # returns the next page number or the last
    # WillPaginate hook
    def next_page
      @next_page ||= (current_page < total_pages) ? current_page + 1 : total_pages
    end
  end
  
  def paginator
    @paginator ||= Paginator.new(start, rows, total)
  end
  
  # The main select response class.
  # Includes the top level Response::Base module
  # Includes the Pagination module.
  # Each solr hash doc is extended by the DocExt module.
  
  include RSolrExt::Response::Base
  include Facets
  
  def response
    self[:response]
  end
  
  def num_found
    response[:numFound]
  end
  
  def start
    response[:start]
  end
  
  def rows
    params[:rows]
  end
  
  alias :total :num_found
  alias :offset :start
  
  def docs
    @docs ||= response[:docs].collect{ |d| d=d.to_mash; d.extend(DocExt); d }
  end
  
  # converts to mash, then extends
  def self.create(hash)
    mash = hash.is_a?(Mash) ? hash : hash.to_mash
    mash.extend self
    mash
  end
  
end # end Select