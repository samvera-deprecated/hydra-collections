module Hydra::Collections
  module Relations
    extend ActiveSupport::Concern
    included do
      has_and_belongs_to_many :members, predicate: ActiveFedora::RDF::Fcrepo::RelsExt.hasCollectionMember, class_name: "ActiveFedora::Base"
    end
  end
end
