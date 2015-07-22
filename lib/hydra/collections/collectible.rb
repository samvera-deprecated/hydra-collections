# This module adds a `has_many :collections` association to any models that you mix it into, using the :has_collection_member property
# It also provides methods to help you index the information as a facet
require 'deprecation'
module Hydra::Collections
  module Collectible
    extend ActiveSupport::Concern
    extend Deprecation

    included do
      include Hydra::Works::GenericWorkBehavior
      Deprecation.warn(Collectible, "Hydra::Collections::Collectible is deprecated. include Hydra::Works::GenericWorkBehavior instead. Hydra::Collections::Collectible will be removed in Hydra::Collections 7.0")
    end

    def collection_ids
      Deprecation.warn(Collectible, "collection_ids is deprecated and will be removed in Hydra::Collections 7.0. Use parent_collections.map(&:id) instead.")
      parent_collections.map(&:id)
    end

    def collections
      Deprecation.warn(Collectible, "collections is deprecated and will be removed in Hydra::Collections 7.0. Use parent_collections instead.")
      parent_collections
    end

  end
end
