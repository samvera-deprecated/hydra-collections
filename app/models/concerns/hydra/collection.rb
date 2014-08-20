module Hydra
  module Collection
    extend ActiveSupport::Concern
    extend ActiveSupport::Autoload
    include Hydra::ModelMethods # for access to apply_depositor_metadata
    include Hydra::AccessControls::Permissions
    include Hydra::Collections::Collectible

    included do
      has_metadata "descMetadata", type: Hydra::CollectionRdfDatastream

      has_and_belongs_to_many :members, property: :has_collection_member, class_name: "ActiveFedora::Base" , after_remove: :update_member

      property :depositor, predicate: RDF::URI.new("http://id.loc.gov/vocabulary/relators/dpt")

      # Hack until https://github.com/no-reply/ActiveTriples/pull/37 is merged
      def depositor_with_first
        depositor_without_first.first
      end
      alias_method_chain :depositor, :first

      has_attributes :title, :date_uploaded, :date_modified, :description,
                     datastream: :descMetadata, multiple: false
      has_attributes :creator, :contributor, :based_near, :part_of, :publisher,
                     :date_created, :subject,:resource_type, :rights,
                     :identifier, :language, :tag, :related_url,
                     datastream: :descMetadata, multiple: true

      before_create :set_date_uploaded
      before_save :set_date_modified

      # TODO: Not sure if F4 can do this yet
      after_save :update_all_members
      before_destroy :update_all_members

      include Hydra::Collections::DirtyMembers
    end

    def terms_for_editing
      terms_for_display - [:date_modified, :date_uploaded]
    end

    def terms_for_display
      self.descMetadata.class.config.keys.map{|v| v.to_sym}
    end

    def update_all_members
      self.members.collect { |m| update_member(m) }
    end

    # Re-index each member of the collection
    # This can be overridden as a batch job for large collections
    def update_all_members
      removed_members.each do |member_id|
        ActiveFedora::Base.find(member_id).update_index
      end
      members.each do |member|
        member.update_index
      end
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
