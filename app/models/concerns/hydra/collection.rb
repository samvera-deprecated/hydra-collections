
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

      has_and_belongs_to_many :members, :property => :has_collection_member, :class_name => "ActiveFedora::Base" , :after_remove => :update_member

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

      before_destroy :remove_all_members
    end

    def terms_for_editing
      terms_for_display - [:date_modified, :date_uploaded]
    end

    def terms_for_display
      self.descMetadata.class.config.keys.map{|v| v.to_sym}
    end

    def update_member member
      member.update_index
    end

    # Re-index each member of the collection
    # This can be overridden as a batch job for large collections
    def update_all_members
      self.members.each do |member|
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

    def remove_all_members
      self.members.each do |member|
        member.collections.delete(self) if member.respond_to?(:collections)
      end
    end

 end

end
