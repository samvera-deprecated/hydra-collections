module Hydra
  module Collection
    extend ActiveSupport::Concern
    extend ActiveSupport::Autoload
    include Hydra::ModelMethods # for access to apply_depositor_metadata
    include Hydra::AccessControls::Permissions
    include Hydra::Collections::Collectible

    included do
      has_and_belongs_to_many :members, predicate: ActiveFedora::RDF::Fcrepo::RelsExt.hasCollectionMember, class_name: "ActiveFedora::Base" , after_remove: :update_member

      property :depositor, predicate: RDF::URI.new("http://id.loc.gov/vocabulary/relators/dpt")

      property :part_of, predicate: RDF::DC.isPartOf
      property :contributor, predicate: RDF::DC.contributor do |index|
        index.as :stored_searchable, :facetable
      end
      property :creator, predicate: RDF::DC.creator do |index|
        index.as :stored_searchable, :facetable
      end
      property :title, predicate: RDF::DC.title do |index|
        index.as :stored_searchable
      end
      property :description, predicate: RDF::DC.description do |index|
        index.type :text
        index.as :stored_searchable
      end
      property :publisher, predicate: RDF::DC.publisher do |index|
        index.as :stored_searchable, :facetable
      end
      property :date_created, predicate: RDF::DC.created do |index|
        index.as :stored_searchable
      end
      property :date_uploaded, predicate: RDF::DC.dateSubmitted do |index|
        index.type :date
        index.as :stored_sortable
      end
      property :date_modified, predicate: RDF::DC.modified do |index|
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

      # Single-valued properties
      def depositor
        super.first
      end

      def title
        super.first
      end

      def date_uploaded
        super.first
      end

      def date_modified
        super.first
      end

      def description
        super.first
      end

      before_create :set_date_uploaded
      before_save :set_date_modified
      before_destroy :update_all_members

      after_save :update_all_members
    end

    def terms_for_editing
      terms_for_display - [:date_modified, :date_uploaded]
    end

    def terms_for_display
      [
        :part_of, :contributor, :creator, :title, :description, :publisher, 
        :date_created, :date_uploaded, :date_modified, :subject, :language, :rights, 
        :resource_type, :identifier, :based_near, :tag, :related_url
      ]
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
