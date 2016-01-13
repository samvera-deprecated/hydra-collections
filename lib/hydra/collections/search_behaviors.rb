module Hydra::Collections::SearchBehaviors

  def collection
    scope.collection
  end

  # include filters into the query to only include the collection memebers
  def include_collection_ids(solr_parameters)
    solr_parameters[:fq] ||= []
    solr_parameters[:fq] << "{!join from=hasCollectionMember_ssim to=id}id:#{collection.id}"
  end

  def some_rows(solr_parameters)
    solr_parameters[:rows] = '100'
  end

  def add_collection_filter(solr_parameters)
    solr_parameters[:fq] ||= []
    solr_parameters[:fq] << ActiveFedora::SolrQueryBuilder.construct_query_for_rel(has_model: ::Collection.to_class_uri)
  end

  # Sort results by title if no query was supplied.
  # This overrides the default 'relevance' sort.
  def sort_by_title(solr_parameters)
    return if solr_parameters[:q]
    solr_parameters[:sort] ||= "#{sort_field} asc"
  end

  def discovery_perms= perms
    @discovery_perms = perms
  end

  def discovery_permissions
    @discovery_perms || super
  end

  def sort_field
    Solrizer.solr_name('title', :sortable)
  end

end
