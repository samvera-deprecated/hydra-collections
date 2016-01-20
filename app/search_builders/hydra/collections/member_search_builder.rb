module Hydra::Collections
  class MemberSearchBuilder < Hydra::SearchBuilder
    # Defines which search_params_logic should be used when searching for Collection members
    self.default_processor_chain += [:include_collection_ids]

    def collection
      scope.collection
    end

    # include filters into the query to only include the collection memebers
    def include_collection_ids(solr_parameters)
      solr_parameters[:fq] ||= []
      solr_parameters[:fq] << "{!join from=hasCollectionMember_ssim to=id}id:#{collection.id}"
    end

  end
end
