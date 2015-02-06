module Hydra::Collections
  class SearchBuilder < Hydra::SearchBuilder

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

    def discovery_perms= perms
      @discovery_perms = perms
    end

    def discovery_permissions
      @discovery_perms || super
    end
  end
end
