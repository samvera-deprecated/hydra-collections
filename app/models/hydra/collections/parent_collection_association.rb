module Hydra::Collections
  class ParentCollectionAssociation < ActiveFedora::Associations::CollectionAssociation
      def load_target
        ActiveFedora::QueryResultBuilder.reify_solr_results(load_from_solr(rows: 1000))
      end

    protected
      def find_reflection
        'members'.freeze
      end

      # Overriden so that there are no callbacks.
      def callbacks_for(*)
        []
      end

      def insert_record(*)
        raise NotImplementedError, "#{self.class} is a read-only association."
      end

      # def load_from_solr(opts={})
      #   finder_query = construct_query
      #   return [] if finder_query.empty?
      #   rows = opts.delete(:rows) { count }
      #   return [] if rows == 0
      #   SolrService.query(finder_query, { rows: rows }.merge(opts))
      # end

      def construct_query
        @solr_query ||= begin
          ActiveFedora::SolrQueryBuilder.construct_query_for_rel(find_reflection => @owner.id)
        end
      end
  end
end
