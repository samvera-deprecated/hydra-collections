require 'hydra/head'
require 'hydra/datastreams/collection_rdf_datastream'

module Hydra
  module Collection
    extend ActiveSupport::Concern
    extend ActiveSupport::Autoload
    autoload :Permissions
   include Hydra::ModelMethods # for access to apply_depositor_metadata
   include Hydra::ModelMixins::RightsMetadata
    
   included do
      has_metadata :name => "descMetadata", :type => CollectionRdfDatastream
      has_metadata :name => "properties", :type => Hydra::Datastream::Properties
      has_metadata :name => "rightsMetadata", :type => Hydra::Datastream::RightsMetadata

      has_and_belongs_to_many :members, :property => :has_collection_member, :class_name => "ActiveFedora::Base"

      delegate_to :properties, [:depositor], :unique => true
      delegate_to :descMetadata, [:date_uploaded, :date_modified,
                                  :title, :description], :unique => true

      before_create :set_date_uploaded
      before_save :set_date_modified
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
      self.descMetadata.class.config.keys
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
