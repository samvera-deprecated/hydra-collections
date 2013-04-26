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

require 'spec_helper'

describe CollectionsController do
  before do
    controller.stub(:has_access?).and_return(true)

    @user = FactoryGirl.find_or_create(:user)
    sign_in @user
    User.any_instance.stub(:groups).and_return([])
    controller.stub(:clear_session_user) ## Don't clear out the authenticated session
  end

  describe '#new' do
    it 'should assign @collection' do
      get :new
      expect(assigns(:collection)).to be_kind_of(Collection)
    end
    it "should pass through batch ids if provided and stick them in the form"
  end
  
  describe '#create' do
    it "should create a Collection" do
      old_count = Collection.count
      post :create, collection: {title: "My First Collection ", description: "The Description\r\n\r\nand more"}
      Collection.count.should == old_count+1
      assigns[:collection].title.should == "My First Collection "
      assigns[:collection].description.should == "The Description\r\n\r\nand more"
      assigns[:collection].depositor.should == @user.user_key
      response.should redirect_to Hydra::Collections::Engine.routes.url_helpers.collection_path(assigns[:collection].id)
    end
    it "should add docs to collection if batch ids provided"
  end
  
  describe "#update" do
    before do
      @collection = Collection.new
      @collection.apply_depositor_metadata(@user.user_key)
      @collection.save
      @asset1 = ActiveFedora::Base.create!
      @asset2 = ActiveFedora::Base.create!
      @asset3 = ActiveFedora::Base.create!
      controller.should_receive(:authorize!).and_return(true)
    end
    it "should update collection metadata" do
      put :update, id: @collection.id, collection: {title: "New Title", description: "New Description"}
      response.should redirect_to Hydra::Collections::Engine.routes.url_helpers.collection_path(@collection.id)
      assigns[:collection].title.should == "New Title"
      assigns[:collection].description.should == "New Description"
    end
    it "should support adding batches of members" do
      @collection.members << @asset1
      @collection.save
      put :update, id: @collection.id, collection: {members:"add"}, batch_document_ids:[@asset2, @asset3]
      response.should redirect_to Hydra::Collections::Engine.routes.url_helpers.collection_path(@collection.id)
      assigns[:collection].members.should == [@asset2, @asset3, @asset1]
    end
    it "should support removing batches of members" do
      @collection.members = [@asset1, @asset2, @asset3]
      @collection.save
      put :update, id: @collection.id, collection: {members:"remove"}, batch_document_ids:[@asset1, @asset3]
      response.should redirect_to Hydra::Collections::Engine.routes.url_helpers.collection_path(@collection.id)
      assigns[:collection].members.should == [@asset2]
    end
    it "should support setting members array" do
      put :update, id: @collection.id, collection: {members:"add"}, batch_document_ids:[@asset2, @asset3, @asset1]
      response.should redirect_to Hydra::Collections::Engine.routes.url_helpers.collection_path(@collection.id)
      assigns[:collection].members.should == [@asset1,@asset2, @asset3]
    end
  end
end
