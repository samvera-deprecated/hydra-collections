require 'datastreams/collection_rdf_datastream'
require 'datastreams/properties_datastream'

module Hydra
  module Collection
    extend ActiveSupport::Concern
    extend ActiveSupport::Autoload
    autoload :Permissions
    #TODO Should we remove the three lines below
    include Sufia::ModelMethods
    include Sufia::Noid
    include Sufia::GenericFile::Permissions

    included do
      has_metadata :name => "descMetadata", :type => CollectionRdfDatastream
      has_metadata :name => "properties", :type => PropertiesDatastream

      has_and_belongs_to_many :generic_files, :property => :has_collection_member

      delegate_to :properties, [:depositor], :unique => true
      delegate_to :descMetadata, [:date_uploaded, :date_modified, :related_url,
                                  :title, :description], :unique => true

      before_create :set_date_uploaded
      before_save :set_date_modified
    end

    def to_solr(solr_doc={}, opts={})
      super(solr_doc, opts)
      solr_doc[Solrizer.solr_name("noid", :text, :sortable)] = noid
      return solr_doc
    end

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
