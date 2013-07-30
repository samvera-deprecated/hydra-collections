include Blacklight::SolrHelper

module Hydra
  module CollectionsControllerBehavior
    extend ActiveSupport::Concern

    included do
      include Hydra::Controller::ControllerBehavior
      include Blacklight::Configurable # comply with BL 3.7
      include Blacklight::Controller
      include Hydra::Collections::AcceptsBatches
      include Hydra::Collections::SelectsCollections

      # This is needed as of BL 3.7
      self.copy_blacklight_config_from(CatalogController)

      # Catch permission errors
      rescue_from Hydra::AccessDenied, CanCan::AccessDenied do |exception|
        if (exception.action == :edit)
          redirect_to(collections.url_for({:action=>'show'}), :alert => "You do not have sufficient privileges to edit this document")
        elsif current_user and current_user.persisted?
          redirect_to root_url, :alert => exception.message
        else
          session["user_return_to"] = request.url
          redirect_to new_user_session_url, :alert => exception.message
        end
      end

      # actions: audit, index, create, new, edit, show, update, destroy, permissions, citation
      before_filter :authenticate_user!, :except => [:show]
      load_and_authorize_resource :except=>[:index], instance_name: :collection

      #This includes only the collection members in the search
      self.solr_search_params_logic += [:include_collection_ids]
    end

    def new
    end

    def show
      query_collection_members
    end

    def edit
      query_collection_members
      find_collections
    end

    def after_create
      respond_to do |format|
        format.html { redirect_to collections.collection_path(@collection), notice: 'Collection was successfully created.' }
        format.json { render json: @collection, status: :created, location: @collection }
      end
    end
    
    def after_create_error
      respond_to do |format|
        format.html { render action: "new" }
        format.json { render json: @collection.errors, status: :unprocessable_entity }
      end
    end
        
    def create
      @collection.apply_depositor_metadata(current_user.user_key)
      unless batch.empty?
        params[:collection][:members]="add"
        process_member_changes
      end
      if @collection.save
        after_create
      else
        after_create_error
      end
    end
    
    def after_update 
      if flash[:notice].nil?
        flash[:notice] = 'Collection was successfully updated.'
      end
      respond_to do |format|
        format.html { redirect_to collections.collection_path(@collection) }
        format.json { render json: @collection, status: :updated, location: @collection }
      end
    end
    
    def after_update_error
      respond_to do |format|
        format.html { render action: collections.edit_collection_path(@collection) }
        format.json { render json: @collection.errors, status: :unprocessable_entity }
      end
    end
    
    def update
      process_member_changes
      @collection.update_attributes(params[:collection].except(:members))
      if @collection.save
        after_update
      else
        after_update_error
      end
    end
    
    
    def after_destroy (id)
      respond_to do |format|
        format.html { redirect_to catalog_index_path, notice: 'Collection was successfully deleted.' }
        format.json { render json: {id:id}, status: :destroyed, location: @collection }
      end      
    end

    def after_destroy_error (id)
      respond_to do |format|
        format.html { redirect_to catalog_index_path, notice: 'Collection could not be deleted.' }
        format.json { render json: {id:id}, status: :destroy_error, location: @collection }
      end      
    end
    
    def destroy
       if @collection.destroy
          after_destroy(params[:id])
       else
         after_destroy_error(params[:id])
       end
     end
    
    protected
    
    # Queries Solr for members of the collection.  
    # Populates @response and @member_docs similar to Blacklight Catalog#index populating @response and @documents
    def query_collection_members
      # run the solr query to find the collections
      query = params[:cq]
      (@response, @member_docs) = get_search_results(:q => query, :rows=>100)
    end
    
    def process_member_changes
      unless params[:collection].nil?
        change_members = []
        batch.each do |pid|
          change_members << ActiveFedora::Base.find(pid, :cast=>true)
        end

        case params[:collection][:members]
          when "add"
            change_members.each do |member|
              @collection.members << member
              #@collection.add_relationship(:has_collection_member, "info:fedora/#{pid}")
            end
          when "remove"
            change_members.each do |member|
              @collection.members.delete(member)
            end
          when "move"
            @destination_collection = ::Collection.find(params[:destination_collection_id])
            change_members.each do |member|
              @collection.members.delete(member)
              @destination_collection.members << member
            end
            @destination_collection.save
            flash[:notice] = "Successfully moved #{change_members.count} files to #{@destination_collection.title} Collection."
          when Array
            @collection.members.replace(change_members)
          #@collection.clear_relationship(:has_collection_member)
          #params[:collection][:members].each do |pid|
          #  @collection.add_relationship(:has_collection_member, "info:fedora/#{pid}")
          #end
        end
      end
    end
    
    # this is only needed until the version of balcklight that we are using this include it in it's solr helper  
    def blacklight_solr
        Blacklight.solr
    end

    # include filters into the query to only include the collection memebers
    def include_collection_ids(solr_parameters, user_parameters)
      solr_parameters[:fq] ||= []
      if @collection.member_ids.empty?
        solr_parameters[:fq] << '{!lucene}-id:[* TO *]' # Don't match anything
      else
        query = @collection.member_ids.map{|id| 'id:"'+id+'"'}.join " OR "
        solr_parameters[:fq] << query
      end
    end
  end # module CollectionsControllerBehavior
end # module Hydra
