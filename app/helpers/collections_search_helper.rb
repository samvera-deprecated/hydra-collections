# View Helper methods for Hydra Collections in search results
module CollectionsSearchHelper
  
  def collection_name(collection_pid)
    # junk, pid = collection_pid.split('/')
    escaped_pid = collection_pid.sub(':', '\:')
    solr_opts = {params: {:q=>"id:#{escaped_pid}"}}
    result = Blacklight.solr.get("select", solr_opts)
    docs = result["response"]["docs"]
    
    if docs
      if docs.first[Solrizer.solr_name(:title, :displayable)] 
        res = docs.first[Solrizer.solr_name(:title, :displayable)] 
        res.kind_of?(Array) ? res.first : res 
      else
        logger.warn "#{docs.first['id']} does not have a #{Solrizer.solr_name(:title, :displayable)} in solr"
        docs.first['id']
      end
    else 
      'Not Found'
    end
  end
  
  def display_value_for_facet(facet, value)
      if facet == Solrizer.solr_name(:collection, :facetable)
        collection_name(value)
      elsif ['release_date_desc_facet', 'last_update_date_desc_facet'].include? facet
        Narm::DateFacet.decode(value)
      else
        value
      end
    end
  
end