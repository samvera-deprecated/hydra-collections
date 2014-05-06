module Hydra
  class CollectionRdfDatastream < ActiveFedora::NtriplesRDFDatastream
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

    def prefix
      ""
    end
  end
end
