module Hydra::Collections
  class SearchBuilder < Blacklight::Solr::SearchBuilder

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
      solr_parameters[:fq] << "#{Solrizer.solr_name("has_model", :symbol)}:Collection"
    end
  end
end
