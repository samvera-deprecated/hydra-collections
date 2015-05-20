# This module adds a `has_many :collections` association to any models that you mix it into, using the :has_collection_member property
# It also provides methods to help you index the information as a facet
require 'deprecation'
module Hydra::Collections
  module Collectible
    extend ActiveSupport::Concern
    extend Deprecation
    self.deprecation_horizon = "hydra-collections 4.0"

    # Find the collections that contain this object
    def collections(force_reload = false)
      @reflection ||= ActiveFedora::Reflection::AssociationReflection.new(:parent_collection, :collections, { class_name: 'ActiveFedora::Base' } , self)
      @parent_collections ||= ParentCollectionAssociation.new(self, @reflection)
      @parent_collections.reader(force_reload)
    end

    # Add this method to your solrization logic (ie. in to_solr) in order to populate the 'collection' facet
    # with the pids of any collections that contain the current object.
    # @example
    #   def to_solr(solr_doc={}, opts={})
    #    super(solr_doc, opts)
    #    index_collection_ids(solr_doc)
    #    return solr_doc
    #   end
    def index_collection_ids(solr_doc={})
      Deprecation.warn(Hydra::Collections::Collectible, 'index_collection_ids is deprecated and will be removed in version 5.0')
      # CollectionAssociation#ids_reader loads from solr on each call, so only call it once
      # see https://github.com/projecthydra/active_fedora/issues/644
      ids = collection_ids
      solr_doc[Solrizer.solr_name(:collection, :facetable)] = ids
      solr_doc[Solrizer.solr_name(:collection)] = ids
      solr_doc
    end

    def index_collection_pids(solr_doc={})
      index_collection_ids(solr_doc)
    end
    deprecation_deprecate :index_collection_pids

  end
end
