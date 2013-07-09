require 'hydra/head'
require 'hydra/datastreams/collection_rdf_datastream'

module Hydra
  module Collection
    extend ActiveSupport::Concern
    extend ActiveSupport::Autoload
    autoload :Permissions
    include Hydra::ModelMethods # for access to apply_depositor_metadata
    include Hydra::ModelMixins::RightsMetadata
    include Hydra::Collections::Collectible

    included do
      has_metadata :name => "descMetadata", :type => CollectionRdfDatastream
      has_metadata :name => "properties", :type => Hydra::Datastream::Properties
      has_metadata :name => "rightsMetadata", :type => Hydra::Datastream::RightsMetadata

      has_and_belongs_to_many :members, :property => :has_collection_member, :class_name => "ActiveFedora::Base" , :after_remove => :remove_member

      delegate_to :properties, [:depositor], :unique => true
      
      delegate_to :descMetadata, [:title, :date_uploaded, :date_modified,
                                  :description], :unique => true         
      delegate_to :descMetadata, [:creator, :contributor, :based_near, :part_of, 
                                :publisher, :date_created, :subject,:resource_type, :rights, :identifier,
                                :language, :tag, :related_url]                            

      before_create :set_date_uploaded
      before_save :set_date_modified

      after_save :local_update_members
      after_create :create_member_index

      before_destroy :remove_all_members
    end

    # TODO: Move this override into ScholarSphere
    #def to_solr(solr_doc={}, opts={})
    #  super(solr_doc, opts)
    #  solr_doc[Solrizer.solr_name("noid", :sortable, :type => :text)] = noid
    #  return solr_doc
    #end

    def terms_for_editing
      terms_for_display - [:date_modified, :date_uploaded]
    end

    def terms_for_display
      self.descMetadata.class.config.keys.map{|v| v.to_sym}
    end

    def remove_member(member)
      #member.collections.delete self if member.respond_to?(:collections)
      member.reload.update_index
    end

    private

    def set_date_uploaded
      self.date_uploaded = Date.today
    end

    def set_date_modified
      self.date_modified = Date.today
    end

    # cause the members to index the relationship
    def local_update_members
      if self.respond_to?(:members)
        self.members.each do |member|
          member.reload.update_index
        end
      end
    end

    def create_member_index
      self.members.each do |member|
        member.to_solr  # not sure why this to_solr is needed but it caused the removal and update to work
        if member.respond_to?(:collections)
          member.collections << self
          member.update_index
          member.collections << self if self.members.size == 1  #again who konw why but this allows on asset to be added
        end
      end
    end

    def remove_all_members
      self.members.each do |member|
        member.to_solr  # not sure why this to_solr is needed but it caused the removal and update to work
        member.collections.delete(self) if member.respond_to?(:collections)
        member.update_index
      end
    end

 end

end
