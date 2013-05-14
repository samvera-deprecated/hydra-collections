require 'blacklight'

# -*- coding: utf-8 -*-
# Copyright © 2012 The Pennsylvania State University
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
include Blacklight::SolrHelper

module Hydra
  module CollectionsControllerBehavior
    extend ActiveSupport::Concern

    included do
      include Hydra::Controller::ControllerBehavior
      include Blacklight::Configurable # comply with BL 3.7
      include Hydra::Collections::AcceptsBatches

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
      load_and_authorize_resource :except=>[:index]
    end

    def new
      #@collection = ::Collection.new
    end

    def show
      logger.warn "Got to show"

      if @collection.member_ids.length > 0
        query = @collection.member_ids.join " OR "
        
        # run the solr query to find the collections
        (@response, @member_docs) = get_search_results(:q => query, :rows=>100)
      else
        @member_docs = []
        @response =  {}
      end

    end
        
    def edit
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
      respond_to do |format|
        format.html { redirect_to collections.collection_path(@collection), notice: 'Collection was successfully updated.' }
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
      @collection = ::Collection.find(params[:id])
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
      @collection = ::Collection.find(params[:id])     
       if @collection.destroy
          after_destroy(params[:id])
       else
         after_destroy_error(params[:id])
       end
     end
    
    protected
    
    def process_member_changes
      unless params[:collection].nil?
        case params[:collection][:members]
        when "add"
          batch.each do |pid|
            @collection.add_relationship(:has_collection_member, "info:fedora/#{pid}")
          end
        when "remove"
          batch.each do |pid|
            @collection.remove_relationship(:has_collection_member, "info:fedora/#{pid}")
          end
        when Array
          @collection.clear_relationship(:has_collection_member)
          params[:collection][:members].each do |pid|
            @collection.add_relationship(:has_collection_member, "info:fedora/#{pid}")
          end
        end
      end
    end  
    
    # this is only needed until the version of balcklight that we are using this include it in it's solr helper  
    def blacklight_solr
        Blacklight.solr
    end
    
  end # module CollectionsControllerBehavior
end # module Hydra
