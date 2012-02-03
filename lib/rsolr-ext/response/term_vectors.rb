
module RSolr::Ext::Doc::TermVectors
  
  # doc.term_vectors[:field]["word"]
  # doc.term_vectors[:field]["word"][:tf] = Integer
  # doc.term_vectors[:field]["word"][:offsets] = Array<Range>
  # doc.term_vectors[:field]["word"][:offsets][0] = Range
  # # ...
  # doc.term_vectors[:field]["word"][:positions] = Array<Integer>
  # doc.term_vectors[:field]["word"][:positions][0] = Integer
  # # ...
  # doc.term_vectors[:field]["word"][:df] = Float
  # doc.term_vectors[:field]["word"][:tfidf] = Float
  # doc.term_vectors[:field]["otherword"]
  # # ...
  # doc.term_vectors[:other_field]
  # # ...
  def term_vectors
    return {} unless @term_vector_arrays
    
    @term_vectors ||= (
      ret = {}
      @term_vector_arrays.each do |field, array|
        field_term_vectors = {}
      
        (0...array.length).step(2) do |i|
          term = array[i]
          term.force_encoding("UTF-8") if RUBY_VERSION >= "1.9.0"
          attr_array = array[i + 1]
          hash = {}
      
          (0...attr_array.length).step(2) do |j|
            key = attr_array[j]
            val = attr_array[j+1]
        
            case key
            when 'tf'
              hash[:tf] = Integer(val)
            when 'offsets'
              hash[:offsets] = []
              (0...val.length).step(4) do |k|
                s = Integer(val[k+1])
                e = Integer(val[k+3])
                hash[:offsets] << (s...e)
              end
            when 'positions'
              hash[:positions] = []
              (0...val.length).step(2) do |k|
                p = Integer(val[k+1])
                hash[:positions] << p
              end
            when 'df'
              hash[:df] = Float(val)
            when 'tf-idf'
              hash[:tfidf] = Float(val)
            end
          end
      
          field_term_vectors[term] = hash
        end
      
        ret[field.to_sym] = field_term_vectors
      end
      ret
    )
  end
  
end

module RSolr::Ext::Response::TermVectors
  
  def self.extended(base)
    return unless base['termVectors']
    return unless base['response']['docs']
    
    documents = base['response']['docs']
    
    # Dig up the unique key field name
    unique_field_name = nil
    if base['termVectors'][-2] == 'uniqueKeyFieldName'
      unique_field_name = base['termVectors'][-1]
    end
    
    # Parse all of the term vector arrays
    #
    # Array format:
    #
    #   [ 'doc-N', [ 'uniqueKey', '(key value)', 
    #     '(term vector field)', [
    #       'term', [
    #         'tf', 1,
    #         'offsets', ['start', 100, 'end', 110],
    #         'positions', ['position', 50],
    #         'df', 1,
    #         'tf-idf', 0.234],
    #       'term2', ... ], ... ],
    #   'uniqueKeyFieldName', '(field name)' ]
    #
    # The last two items in this array are 'uniqueKeyFieldName' 
    # and the unique key, which we queried above.
    (0...(base['termVectors'].length - 2)).step(2) do |i|
      document_array = base['termVectors'][i + 1]
      unique_key = document_array[1]
      
      # Find a document with that unique key
      doc = documents.detect do |doc|
        if unique_field_name
          doc[unique_field_name] == unique_key
        else
          doc.has_value? unique_key
        end
      end      
      next unless doc
      
      # Make a hash pointing fields to arrays
      term_hash = {}
      
      (2...document_array.length).step(2) do |j|
        term = document_array[j]
        term_array = document_array[j + 1]
        
        term_hash[term] = term_array
      end
      
      doc.instance_variable_set(:@term_vector_arrays, term_hash)
      doc.extend RSolr::Ext::Doc::TermVectors
    end
  end
  
end
