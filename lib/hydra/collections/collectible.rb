# This module adds a `has_many :collections` association to any models that you mix it into, using the :has_collection_member property
# It also provides methods to help you index the information as a facet
module Hydra::Collections::Collectible
  extend ActiveSupport::Autoload
  extend ActiveSupport::Concern
  
  included do
    #after_solrize << :index_collection_pids
    has_many :collections, property: :has_collection_member
  end

  # Add this method to your solrization logic (ie. in to_solr) in order to populate the 'collection' facet 
  # with the pids of any collections that contain the current object.
  # @example
  #   def to_solr(solr_doc={}, opts={})
  #    super(solr_doc, opts)
  #    index_collection_pids(solr_doc)
  #    return solr_doc
  #   end
  def index_collection_pids(solr_doc={})
    solr_doc[Solrizer.solr_name(:collection, :facetable)] = self.collection_ids
    solr_doc[Solrizer.solr_name(:collection)] = self.collection_ids
    solr_doc
  end
end