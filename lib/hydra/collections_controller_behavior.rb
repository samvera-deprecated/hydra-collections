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

module Hydra
  module CollectionsControllerBehavior
    extend ActiveSupport::Concern

    included do
      include Hydra::Controller::ControllerBehavior
      include Blacklight::Configurable # comply with BL 3.7

      # This is needed as of BL 3.7
      self.copy_blacklight_config_from(CatalogController)

      # Catch permission errors
      rescue_from Hydra::AccessDenied, CanCan::AccessDenied do |exception|
        if (exception.action == :edit)
          redirect_to(sufia.url_for({:action=>'show'}), :alert => "You do not have sufficient privileges to edit this document")
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
    
    def edit
    end
    
    def create
      @collection.apply_depositor_metadata(current_user.user_key)
      respond_to do |format|
        if @collection.save
          format.html { redirect_to catalog_index_path("f[collection][]"=>@collection.id), notice: 'Collection was successfully created.' }
          format.json { render json: @collection, status: :created, location: @collection }
        else
          format.html { render action: "new" }
          format.json { render json: @collection.errors, status: :unprocessable_entity }
        end
      end
    end
    
    def update
    end
    
  end
end
