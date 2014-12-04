module Hydra
  module Collection
    extend ActiveSupport::Concern
    extend ActiveSupport::Autoload
    include Hydra::ModelMethods # for access to apply_depositor_metadata
    include Hydra::AccessControls::Permissions
    include Hydra::Collections::Collectible

    included do
      has_metadata "descMetadata", type: Hydra::CollectionRdfDatastream
      has_metadata "properties", type: Hydra::Datastream::Properties

      has_and_belongs_to_many :members, property: :has_collection_member, class_name: "ActiveFedora::Base" , after_remove: :update_member

      has_attributes :depositor, datastream: :properties, multiple: false

      has_attributes :title, :date_uploaded, :date_modified, :description,
                     datastream: :descMetadata, multiple: false
      has_attributes :creator, :contributor, :based_near, :part_of, :publisher,
                     :date_created, :subject,:resource_type, :rights,
                     :identifier, :language, :tag, :related_url,
                     datastream: :descMetadata, multiple: true

      before_create :set_date_uploaded
      before_save :set_date_modified

      after_save :update_all_members

      before_destroy :update_all_members
    end

    def terms_for_editing
      terms_for_display - [:date_modified, :date_uploaded]
    end

    def terms_for_display
      self.descMetadata.class.properties.keys.map{|v| v.to_sym}
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
