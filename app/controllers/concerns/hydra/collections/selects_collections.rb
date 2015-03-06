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
  def find_collections (access_level = nil)
    # need to know the user if there is an access level applied otherwise we are just doing public collections
    authenticate_user! unless access_level.blank?

    # run the solr query to find the collections
    query = collections_search_builder(access_level).with({q: ''}).query
    response = repository.search(query)

    # return the user's collections (or public collections if no access_level is applied)
    @user_collections = response.documents
  end

  def collections_search_builder_class
    Hydra::Collections::SearchBuilder
  end

  def collections_search_builder(access_level = nil)
    @collections_search_builder ||= collections_search_builder_class.new(collection_search_params_logic, self).tap do |builder|
      builder.current_ability = current_ability
      builder.discovery_perms = access_levels[access_level] if access_level
    end
  end

  # Defines which search_params_logic should be used when searching for Collections
  def collection_search_params_logic
    [:default_solr_parameters, :add_query_to_solr, :add_access_controls_to_solr_params,
      :add_collection_filter, :some_rows]
  end

end
