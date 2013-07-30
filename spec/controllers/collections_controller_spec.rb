require 'spec_helper'

describe CollectionsController do
  before(:all) do
    @user = FactoryGirl.find_or_create(:user)
    class GenericFile < ActiveFedora::Base
      include Hydra::Collections::Collectible


      attr_accessor :title
      def to_solr(solr_doc={})
        super
        solr_doc = index_collection_pids(solr_doc)
        solr_doc["label_tesim"] = self.title
        solr_doc
      end
    end
  end
  after(:all) do
    @user.destroy
    GenericFile.destroy_all
    Collection.destroy_all
    Object.send(:remove_const, :GenericFile)
  end
  
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
    it "should pass through batch ids if provided and stick them in the form" do
      pending "Couldn't get have_selector working before I had to move on.  - MZ"
      get :new, batch_document_ids: ["test2", "test88"]
      response.should have_selector("p[class='foo']")
    end
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
    it "should add docs to collection if batch ids provided" do
      @asset1 = ActiveFedora::Base.create!
      @asset2 = ActiveFedora::Base.create!
      post :create, batch_document_ids: [@asset1, @asset2], collection: {title: "My Secong Collection ", description: "The Description\r\n\r\nand more"}
      assigns[:collection].members.should == [@asset1, @asset2]
    end
    it "should call after_create" do
       controller.should_receive(:after_create).and_call_original
       post :create, collection: {title: "My First Collection ", description: "The Description\r\n\r\nand more"}
    end

    it "should add one doc to collection if batch ids provided and add the collection id to the document in the colledction" do
      @asset1 = GenericFile.create!
      post :create, batch_document_ids: [@asset1], collection: {title: "My Secong Collection ", description: "The Description\r\n\r\nand more"}
      assigns[:collection].members.should == [@asset1]
      asset_results = Blacklight.solr.get "select", params:{fq:["id:\"#{@asset1.pid}\""],fl:['id',Solrizer.solr_name(:collection)]}
      asset_results["response"]["numFound"].should == 1
      doc = asset_results["response"]["docs"].first
      doc["id"].should == @asset1.pid
      afterupdate = GenericFile.find(@asset1.pid)
      doc[Solrizer.solr_name(:collection)].should == afterupdate.to_solr[Solrizer.solr_name(:collection)]
    end
    it "should add docs to collection if batch ids provided and add the collection id to the documents int he colledction" do
      @asset1 = GenericFile.create!
      @asset2 = GenericFile.create!
      post :create, batch_document_ids: [@asset1,@asset2], collection: {title: "My Secong Collection ", description: "The Description\r\n\r\nand more"}
      assigns[:collection].members.should == [@asset1,@asset2]
      asset_results = Blacklight.solr.get "select", params:{fq:["id:\"#{@asset1.pid}\""],fl:['id',Solrizer.solr_name(:collection)]}
      asset_results["response"]["numFound"].should == 1
      doc = asset_results["response"]["docs"].first
      doc["id"].should == @asset1.pid
      afterupdate = GenericFile.find(@asset1.pid)
      doc[Solrizer.solr_name(:collection)].should == afterupdate.to_solr[Solrizer.solr_name(:collection)]
    end
  end

  describe "#update" do
    before do
      @collection = Collection.new
      @collection.apply_depositor_metadata(@user.user_key)
      @collection.save
      @asset1 = GenericFile.create!
      @asset2 = GenericFile.create!
      @asset3 = GenericFile.create!
      controller.stub(:authorize!).and_return(true)
      controller.should_receive(:authorize!).at_least(:once)
    end
    it "should update collection metadata" do
      put :update, id: @collection.id, collection: {title: "New Title", description: "New Description"}
      response.should redirect_to Hydra::Collections::Engine.routes.url_helpers.collection_path(@collection.id)
      assigns[:collection].title.should == "New Title"
      assigns[:collection].description.should == "New Description"
    end

    it "should call after_update" do
       controller.should_receive(:after_update).and_call_original
       put :update, id: @collection.id, collection: {title: "New Title", description: "New Description"}
    end
    it "should support adding batches of members" do
      @collection.members << @asset1
      @collection.save
      put :update, id: @collection.id, collection: {members:"add"}, batch_document_ids:[@asset2, @asset3]
      response.should redirect_to Hydra::Collections::Engine.routes.url_helpers.collection_path(@collection.id)
      assigns[:collection].members.sort! { |a,b| a.pid <=> b.pid }.should == [@asset2, @asset3, @asset1].sort! { |a,b| a.pid <=> b.pid }
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
      assigns[:collection].members.sort! { |a,b| a.pid <=> b.pid }.should == [@asset2, @asset3, @asset1].sort! { |a,b| a.pid <=> b.pid }
    end
    it "should support setting members array" do
      put :update, id: @collection.id, collection: {members:"add"}, batch_document_ids:[@asset2, @asset3, @asset1]
      response.should redirect_to Hydra::Collections::Engine.routes.url_helpers.collection_path(@collection.id)
      assigns[:collection].members.sort! { |a,b| a.pid <=> b.pid }.should == [@asset2, @asset3, @asset1].sort! { |a,b| a.pid <=> b.pid }
    end
    it "should set/un-set collection on members" do
      # Add to collection (sets collection on members)
      put :update, id: @collection.id, collection: {members:"add"}, batch_document_ids:[@asset2, @asset3]
      assigns[:collection].members.sort! { |a,b| a.pid <=> b.pid }.should == [@asset2, @asset3].sort! { |a,b| a.pid <=> b.pid }
      ## Check that member lists collection in its solr doc
      @asset2.reload
      @asset2.to_solr[Solrizer.solr_name(:collection)].should == [@collection.pid]
      ## Check that member was re-indexed with collection info
      asset_results = Blacklight.solr.get "select", params:{fq:["id:\"#{@asset2.pid}\""],fl:['id',Solrizer.solr_name(:collection)]}
      doc = asset_results["response"]["docs"].first
      doc["id"].should == @asset2.pid
      doc[Solrizer.solr_name(:collection)].should == [@collection.pid]
  
      # Remove from collection (un-sets collection on members)
      put :update, id: @collection.id, collection: {members:"remove"}, batch_document_ids:[@asset2]
      assigns[:collection].members.should_not include(@asset2)
      ## Check that member no longer lists collection in its solr doc
      @asset2.reload
      @asset2.to_solr[Solrizer.solr_name(:collection)].should == []
      ## Check that member was re-indexed without collection info
      asset_results = Blacklight.solr.get "select", params:{fq:["id:\"#{@asset2.pid}\""],fl:['id',Solrizer.solr_name(:collection)]}
      doc = asset_results["response"]["docs"].first
      doc["id"].should == @asset2.pid
      doc[Solrizer.solr_name(:collection)].should be_nil
    end
    
    it "should allow moving members between collections" do
      @collection.members = [@asset1, @asset2, @asset3]
      @collection.save
      @collection2 = Collection.new
      @collection2.apply_depositor_metadata(@user.user_key)
      @collection2.save
      put :update, id: @collection.id, collection: {members:"move"}, destination_collection_id:@collection2.pid, batch_document_ids:[@asset2, @asset3]
      ::Collection.find(@collection.pid).members.should == [@asset1]
      ::Collection.find(@collection2.pid).members.should == [@asset2, @asset3]
    end

  end

  describe "#destroy" do
    describe "valid collection" do
      before do
        @collection = Collection.new
        @collection.apply_depositor_metadata(@user.user_key)
        @collection.save
        controller.should_receive(:authorize!).and_return(true)
      end
      it "should delete collection" do
        delete :destroy, id: @collection.id
        response.should redirect_to Rails.application.routes.url_helpers.catalog_index_path
        flash[:notice].should == "Collection was successfully deleted."
      end
      it "should after_destroy" do
        controller.should_receive(:after_destroy).and_call_original
        delete :destroy, id: @collection.id
      end
      it "should call update members" do
        @asset1 = GenericFile.create!
        @collection.members << @asset1
        @collection.save
        @asset1 = @asset1.reload
        @asset1.update_index
        @asset1.collections.should == [@collection]
        asset_results = Blacklight.solr.get "select", params:{fq:["id:\"#{@asset1.pid}\""],fl:['id',Solrizer.solr_name(:collection)]}
        asset_results["response"]["numFound"].should == 1
        doc = asset_results["response"]["docs"].first
        doc[Solrizer.solr_name(:collection)].should == [@collection.pid]

        delete :destroy, id: @collection.id
        @asset1.reload.collections.should == []
        asset_results = Blacklight.solr.get "select", params:{fq:["id:\"#{@asset1.pid}\""],fl:['id',Solrizer.solr_name(:collection)]}
        asset_results["response"]["numFound"].should == 1
        doc = asset_results["response"]["docs"].first
        doc[Solrizer.solr_name(:collection)].should be_nil
        @asset1.destroy
      end
    end
    it "should not delete an invalid collection" do
       expect {delete :destroy, id: 'zz:-1'}.to raise_error
    end
  end

  describe "#show" do
    before do
      @asset1 = GenericFile.create!(title: "First of the Assets")
      @asset2 = GenericFile.create!(title: "Second of the Assets")
      @asset3 = GenericFile.create!(title: "Third of the Assets")
      @collection = Collection.new
      @collection.title = "My collection"
      @collection.apply_depositor_metadata(@user.user_key)
      @collection.members = [@asset1,@asset2,@asset3]
      @collection.save
      controller.should_receive(:authorize!).and_return(true)
      controller.stub(:apply_gated_search)
    end
    it "should show the collections" do
      get :show, id: @collection.id
      assigns[:collection].title.should == @collection.title
      ids = assigns[:member_docs].map {|d| d.id}
      ids.should include @asset1.pid
      ids.should include @asset2.pid
      ids.should include @asset3.pid
    end
    it "should show only the collections assets" do
      @asset4 = GenericFile.create!(title: "#{@asset1.id}")
      get :show, id: @collection.id
      assigns[:collection].title.should == @collection.title
      ids = assigns[:member_docs].map {|d| d.id}
      ids.should include @asset1.pid
      ids.should include @asset2.pid
      ids.should include @asset3.pid
      ids.should_not include @asset4.pid
    end
    # NOTE: This test depends on title_tesim being in the qf in solrconfig.xml
    it "should query the collections" do
      get :show, id: @collection.id, cq:"\"#{@asset1.title}\""
      assigns[:collection].title.should == @collection.title
      ids = assigns[:member_docs].map {|d| d.id}
      ids.should include @asset1.pid
      ids.should_not include @asset2.pid
      ids.should_not include @asset3.pid
    end

    # NOTE: This test depends on title_tesim being in the qf in solrconfig.xml
    it "should query the collections and show only the collection assets" do
      @asset4 = GenericFile.create!(title: "#{@asset1.id} #{@asset1.title}")
      @asset5 = GenericFile.create!(title: "#{@asset1.title}")
      get :show, id: @collection.id, cq:"\"#{@asset1.title}\""
      assigns[:collection].title.should == @collection.title
      ids = assigns[:member_docs].map {|d| d.id}
      ids.should include @asset1.pid
      ids.should_not include @asset2.pid
      ids.should_not include @asset3.pid
      ids.should_not include @asset4.pid
      ids.should_not include @asset5.pid
    end
  end

end
