require 'blacklight/catalog'

module Hydra::Collections::SelectsCollections

  extend ActiveSupport::Autoload
  extend ActiveSupport::Concern
 
  def access_levels
    {read:[:read,:edit],edit:[:edit]}
  end 

  # add one of the following methods as a before filter on any page that shows the form_for_select_collection
  def find_collections_with_read_access
    find_collections(:read)
  end

  def find_collections_with_edit_access
    find_collections(:edit)
  end
    
  def find_collections (access_level='')
    # need to know the user if there is an access level applied otherwise we are just doing public collections
    authenticate_user! unless access_level.blank?
    
    # update the permission filters for the query of need be
    original_permissions = discovery_permissions 
    self.class.send(:define_method, "discovery_permissions")  { access_levels[access_level] } unless access_level.blank?
 
    # add the collection filter to the solr logic for this query
    orig_solr_search_params_logic = CatalogController.solr_search_params_logic
    CatalogController.solr_search_params_logic += [:add_collection_filter]
    
    # run the solr query to find the collections
    (resp, doc_list) = get_search_results(:q => '', :rows=>100)

    #reset to original solr logic
    self.class.send(:define_method, "discovery_permissions")  { original_permissions } unless access_level.blank?
    CatalogController.solr_search_params_logic = orig_solr_search_params_logic

    # return the user's collections (or public collections if no access_level is applied)
    @user_collections = doc_list
  end
      
  def add_collection_filter(solr_parameters, user_parameters)
    solr_parameters[:fq] ||= []
    solr_parameters[:fq] << "#{Solrizer.solr_name("has_model", :symbol)}:\"info:fedora/afmodel:Collection\""
  end
  
end
