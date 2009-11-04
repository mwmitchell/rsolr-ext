module RSolr::Ext::Response::Facets
  
  # represents a facet value; which is a field value and its hit count
  FacetItem = Struct.new :value,:hits
  
  # represents a facet; which is a field and its values
  FacetField = Struct.new :name, :items do
    def items; @items ||= [] end
  end
  
  # @response.facets.each do |facet|
  #   facet.name
  #   facet.items
  # end
  # "caches" the result in the @facets instance var
  def facets
    @facets ||= (
      facet_fields.map do |(facet_field_name,values_and_hits)|
        facet = FacetField.new(facet_field_name)
        (values_and_hits.size/2).times do |index|
          facet.items << FacetItem.new(values_and_hits[index*2], values_and_hits[index*2+1])
        end
        facet
      end
    )
  end
  
  # pass in a facet field name and get back a Facet instance
  def facet_by_field_name(name)
    @facets_by_field_name ||= {}
    @facets_by_field_name[name] ||= (
      facets.detect{|facet|facet.name.to_s == name.to_s}
    )
  end
  
  def facet_counts
    @facet_counts ||= self['facet_counts'] || {}
  end

  # Returns the hash of all the facet_fields (ie: {'instock_b' => ['true', 123, 'false', 20]}
  def facet_fields
    @facet_fields ||= facet_counts['facet_fields'] || {}
  end

  # Returns all of the facet queries
  def facet_queries
    @facet_queries ||= facet_counts['facet_queries'] || {}
  end
  
end # end Facets