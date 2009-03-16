class RSolr::Ext::Request::Standard
  
  include RSolr::Ext::Request::Mapable
  include RSolr::Ext::Request::Queryable
  
  MAPPED_PARAMS = [
    :per_page,
    :page,
    :phrases, # quoted q param
    :filters, # fq params
    :phrase_filters # quoted fq params
  ]
  
  def map_per_page(value,output)
    output[:rows] = value.to_i
  end
  
  def map_page(value,output)
    raise ':per_page must be set when using :page' unless output[:rows]
    page = value.to_s.to_i-1
    page = page < 1 ? 0 : page
    output[:start] = page * output[:rows]
  end
  
  def map_phrases(value,output)
    output[:q] = append_to_param(output[:q], build_query(value, true))
  end
  
  def map_filters(value,output)
    output[:fq] = append_to_param(output[:fq], build_query(value))
  end
  
  def map_phrase_filters(value,output)
    output[:fq] = append_to_param(output[:fq], build_query(value, true))
  end
    
  
end