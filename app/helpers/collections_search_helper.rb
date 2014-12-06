# View Helper methods for Hydra Collections in search results
module CollectionsSearchHelper

  # @param [String] collection_pid the pid of a collection
  # @return [String] the title of the collection if available, otherwise its pid
  def collection_name(collection_pid)
    #TODO this can be loaded from solr
    # the .result is due to ActiveTriples/ActiveTripes#74
    Collection.find(collection_pid).title.result || collection_pid
  end

end
