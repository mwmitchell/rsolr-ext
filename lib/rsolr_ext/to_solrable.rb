module RSolrExt::ToSolrable
  
  def to_solr
    output = self.dup
    mapped_params.each do |param_name|
      value = output.delete(param_name)
      send("map_#{param_name}", output, value) if value
    end
    output
  end
  
end # end ToSolrable