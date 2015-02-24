module Hydra::Collections::SelectsCollections
  extend ActiveSupport::Concern

  included do
    configure_blacklight do |config|
      config.search_builder_class = Hydra::Collections::SearchBuilder
    end
  end

  def access_levels
    { read: [:read, :edit], edit: [:edit] }
  end

  # add one of the following methods as a before filter on any page that shows the form_for_select_collection
  def find_collections_with_read_access
    find_collections(:read)
  end

  def find_collections_with_edit_access
    find_collections(:edit)
  end

  #
  def find_collections (access_level='')
    # need to know the user if there is an access level applied otherwise we are just doing public collections
    authenticate_user! unless access_level.blank?

    # update the permission filters for the query of need be
    original_permissions = discovery_permissions
    self.class.send(:define_method, "discovery_permissions")  { access_levels[access_level] } unless access_level.blank?

    # run the solr query to find the collections
    (resp, doc_list) = search_results({q: ''},collection_search_params_logic)

    #reset to original discovery logic
    self.class.send(:define_method, "discovery_permissions")  { original_permissions } unless access_level.blank?

    # return the user's collections (or public collections if no access_level is applied)
    @user_collections = doc_list
  end

  # Defines which solr_search_params_logic should be used when searching for Collections
  def collection_search_params_logic
    base_logic = [:default_solr_parameters, :add_query_to_solr, :add_access_controls_to_solr_params]
    base_logic += [:add_collection_filter, :some_rows]
    base_logic
  end

end
