module Hydra
  module Collections
    module SolrDocumentBehavior
      def title_or_label
        title || label
      end
    
      def title
        Array(self[Solrizer.solr_name('desc_metadata__title')]).first
      end
  
      def description
        Array(self[Solrizer.solr_name('desc_metadata__description')]).first
      end
      
    end
  end
end
