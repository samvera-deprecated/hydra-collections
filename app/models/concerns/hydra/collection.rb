module Hydra
  module Collection
    extend ActiveSupport::Concern
    extend ActiveSupport::Autoload
    include Hydra::WithDepositor # for access to apply_depositor_metadata
    include Hydra::AccessControls::Permissions
    include Hydra::Collections::Collectible

    included do
      has_and_belongs_to_many :members, predicate: ActiveFedora::RDF::Fcrepo::RelsExt.hasCollectionMember, class_name: "ActiveFedora::Base" , after_remove: :update_member

      property :depositor, predicate: ::RDF::URI.new("http://id.loc.gov/vocabulary/relators/dpt"), multiple: false do |index|
        index.as :symbol, :stored_searchable
      end

      property :part_of, predicate: RDF::DC.isPartOf
      property :contributor, predicate: RDF::DC.contributor do |index|
        index.as :stored_searchable, :facetable
      end
      property :creator, predicate: RDF::DC.creator do |index|
        index.as :stored_searchable, :facetable
      end
      property :title, predicate: RDF::DC.title, multiple: false do |index|
        index.as :stored_searchable
      end
      property :description, predicate: RDF::DC.description, multiple: false do |index|
        index.type :text
        index.as :stored_searchable
      end
      property :publisher, predicate: RDF::DC.publisher do |index|
        index.as :stored_searchable, :facetable
      end
      property :date_created, predicate: RDF::DC.created do |index|
        index.as :stored_searchable
      end
      property :date_uploaded, predicate: RDF::DC.dateSubmitted, multiple: false do |index|
        index.type :date
        index.as :stored_sortable
      end
      property :date_modified, predicate: RDF::DC.modified, multiple: false do |index|
        index.type :date
        index.as :stored_sortable
      end
      property :subject, predicate: RDF::DC.subject do |index|
        index.as :stored_searchable, :facetable
      end
      property :language, predicate: RDF::DC.language do |index|
        index.as :stored_searchable, :facetable
      end
      property :rights, predicate: RDF::DC.rights do |index|
        index.as :stored_searchable
      end
      property :resource_type, predicate: RDF::DC.type do |index|
        index.as :stored_searchable, :facetable
      end
      property :identifier, predicate: RDF::DC.identifier do |index|
        index.as :stored_searchable
      end
      property :based_near, predicate: RDF::FOAF.based_near do |index|
        index.as :stored_searchable, :facetable
      end
      property :tag, predicate: RDF::DC.relation do |index|
        index.as :stored_searchable, :facetable
      end
      property :related_url, predicate: RDF::RDFS.seeAlso

      before_create :set_date_uploaded
      before_save :set_date_modified
      before_destroy :update_all_members

      after_save :update_all_members
    end

    def update_all_members
      self.members.collect { |m| update_member(m) }
    end

    # TODO: Use solr atomic updates to accelerate this process
    def update_member member
      # because the member may have its collections cached, reload that cache so that it indexes the correct fields.
      member.collections(true) if member.respond_to? :collections
      member.update_index
    end

    private

    def set_date_uploaded
      self.date_uploaded = Date.today
    end

    def set_date_modified
      self.date_modified = Date.today
    end

 end
end
