module Hydra::Collections
  module RequiredMetadata
    extend ActiveSupport::Concern
    included do
      property :depositor, predicate: RDF::Vocab::MARCRelators.dpt, multiple: false do |index|
        index.as :symbol, :stored_searchable
      end
    end
  end
end
