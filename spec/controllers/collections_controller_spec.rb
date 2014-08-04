require 'spec_helper'

describe CollectionsController, :type => :controller do
  before(:all) do
    @user = FactoryGirl.find_or_create(:user)
#    CollectionsController.config.default_solr_params = {:qf => 'title_tesim'}
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
    allow(controller).to receive(:has_access?).and_return(true)

    @user = FactoryGirl.find_or_create(:user)
    sign_in @user
    allow_any_instance_of(User).to receive(:groups).and_return([])
    allow(controller).to receive(:clear_session_user) ## Don't clear out the authenticated session
  end

  describe '#new' do
    it 'should assign @collection' do
      get :new
      expect(assigns(:collection)).to be_kind_of(Collection)
    end
    it "should pass through batch ids if provided and stick them in the form" do
      skip "Couldn't get have_selector working before I had to move on.  - MZ"
      get :new, batch_document_ids: ["test2", "test88"]
      expect(response).to have_selector("p[class='foo']")
    end
  end
  
  describe '#create' do
    it "should create a Collection" do
      old_count = Collection.count
      post :create, collection: {title: "My First Collection ", description: "The Description\r\n\r\nand more"}
      expect(Collection.count).to eq(old_count+1)
      expect(assigns[:collection].title).to eq("My First Collection ")
      expect(assigns[:collection].description).to eq("The Description\r\n\r\nand more")
      expect(assigns[:collection].depositor).to eq(@user.user_key)
      expect(response).to redirect_to Hydra::Collections::Engine.routes.url_helpers.collection_path(assigns[:collection].id)
    end
    it "should add docs to collection if batch ids provided" do
      @asset1 = ActiveFedora::Base.create!
      @asset2 = ActiveFedora::Base.create!
      post :create, batch_document_ids: [@asset1, @asset2], collection: {title: "My Secong Collection ", description: "The Description\r\n\r\nand more"}
      expect(assigns[:collection].members).to eq([@asset1, @asset2])
    end
    it "should call after_create" do
       expect(controller).to receive(:after_create).and_call_original
       post :create, collection: {title: "My First Collection ", description: "The Description\r\n\r\nand more"}
    end

    it "should add one doc to collection if batch ids provided and add the collection id to the document in the colledction" do
      @asset1 = GenericFile.create!
      post :create, batch_document_ids: [@asset1], collection: {title: "My Secong Collection ", description: "The Description\r\n\r\nand more"}
      expect(assigns[:collection].members).to eq([@asset1])
      asset_results = blacklight_solr.get "select", params:{fq:["id:\"#{@asset1.pid}\""],fl:['id',Solrizer.solr_name(:collection)]}
      expect(asset_results["response"]["numFound"]).to eq(1)
      doc = asset_results["response"]["docs"].first
      expect(doc["id"]).to eq(@asset1.pid)
      afterupdate = GenericFile.find(@asset1.pid)
      expect(doc[Solrizer.solr_name(:collection)]).to eq(afterupdate.to_solr[Solrizer.solr_name(:collection)])
    end
    it "should add docs to collection if batch ids provided and add the collection id to the documents int he colledction" do
      @asset1 = GenericFile.create!
      @asset2 = GenericFile.create!
      post :create, batch_document_ids: [@asset1,@asset2], collection: {title: "My Secong Collection ", description: "The Description\r\n\r\nand more"}
      expect(assigns[:collection].members).to eq([@asset1,@asset2])
      asset_results = blacklight_solr.get "select", params:{fq:["id:\"#{@asset1.pid}\""],fl:['id',Solrizer.solr_name(:collection)]}
      expect(asset_results["response"]["numFound"]).to eq(1)
      doc = asset_results["response"]["docs"].first
      expect(doc["id"]).to eq(@asset1.pid)
      afterupdate = GenericFile.find(@asset1.pid)
      expect(doc[Solrizer.solr_name(:collection)]).to eq(afterupdate.to_solr[Solrizer.solr_name(:collection)])
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
      allow(controller).to receive(:authorize!).and_return(true)
      expect(controller).to receive(:authorize!).at_least(:once)
    end
    it "should update collection metadata" do
      put :update, id: @collection.id, collection: {title: "New Title", description: "New Description"}
      expect(response).to redirect_to Hydra::Collections::Engine.routes.url_helpers.collection_path(@collection.id)
      expect(assigns[:collection].title).to eq("New Title")
      expect(assigns[:collection].description).to eq("New Description")
    end

    it "should call after_update" do
       expect(controller).to receive(:after_update).and_call_original
       put :update, id: @collection.id, collection: {title: "New Title", description: "New Description"}
    end
    it "should support adding batches of members" do
      @collection.members << @asset1
      @collection.save
      put :update, id: @collection.id, collection: {members:"add"}, batch_document_ids:[@asset2, @asset3]
      expect(response).to redirect_to Hydra::Collections::Engine.routes.url_helpers.collection_path(@collection.id)
      expect(assigns[:collection].members.sort! { |a,b| a.pid <=> b.pid }).to eq([@asset2, @asset3, @asset1].sort! { |a,b| a.pid <=> b.pid })
    end
    it "should support removing batches of members" do
      @collection.members = [@asset1, @asset2, @asset3]
      @collection.save
      put :update, id: @collection.id, collection: {members:"remove"}, batch_document_ids:[@asset1, @asset3]
      expect(response).to redirect_to Hydra::Collections::Engine.routes.url_helpers.collection_path(@collection.id)
      expect(assigns[:collection].members).to eq([@asset2])
    end
    it "should support setting members array" do
      put :update, id: @collection.id, collection: {members:"add"}, batch_document_ids:[@asset2, @asset3, @asset1]
      expect(response).to redirect_to Hydra::Collections::Engine.routes.url_helpers.collection_path(@collection.id)
      expect(assigns[:collection].members.sort! { |a,b| a.pid <=> b.pid }).to eq([@asset2, @asset3, @asset1].sort! { |a,b| a.pid <=> b.pid })
    end
    it "should support setting members array" do
      put :update, id: @collection.id, collection: {members:"add"}, batch_document_ids:[@asset2, @asset3, @asset1]
      expect(response).to redirect_to Hydra::Collections::Engine.routes.url_helpers.collection_path(@collection.id)
      expect(assigns[:collection].members.sort! { |a,b| a.pid <=> b.pid }).to eq([@asset2, @asset3, @asset1].sort! { |a,b| a.pid <=> b.pid })
    end
    it "should set/un-set collection on members" do
      # Add to collection (sets collection on members)
      solr_doc_before_add = ActiveFedora::SolrInstanceLoader.new(ActiveFedora::Base, @asset2.pid).send(:solr_doc)
      expect(solr_doc_before_add[Solrizer.solr_name(:collection)]).to be_nil
      put :update, id: @collection.id, collection: {members:"add"}, batch_document_ids:[@asset2, @asset3]
      expect(assigns[:collection].members.sort! { |a,b| a.pid <=> b.pid }).to eq([@asset2, @asset3].sort! { |a,b| a.pid <=> b.pid })
      ## Check that member lists collection in its solr doc
      @asset2.reload
      expect(@asset2.to_solr[Solrizer.solr_name(:collection)]).to eq([@collection.pid])
      ## Check that member was re-indexed with collection info
      asset_results = blacklight_solr.get "select", params:{fq:["id:\"#{@asset2.pid}\""],fl:['id',Solrizer.solr_name(:collection)]}
      doc = asset_results["response"]["docs"].first
      expect(doc["id"]).to eq(@asset2.pid)
      expect(doc[Solrizer.solr_name(:collection)]).to eq([@collection.pid])
      solr_doc_after_add = ActiveFedora::SolrInstanceLoader.new(ActiveFedora::Base, @asset2.pid).send(:solr_doc)
      expect(solr_doc_after_add[Solrizer.solr_name(:collection)]).to eq([@collection.pid])

      # Remove from collection (un-sets collection on members)
      solr_doc_before_remove = ActiveFedora::SolrInstanceLoader.new(ActiveFedora::Base, @asset2.pid).send(:solr_doc)
      expect(solr_doc_before_remove[Solrizer.solr_name(:collection)]).to eq([@collection.pid])
      put :update, id: @collection.id, collection: {members:"remove"}, batch_document_ids:[@asset2]
      expect(assigns[:collection].members).not_to include(@asset2)
      ## Check that member no longer lists collection in its solr doc
      @asset2.reload
      expect(@asset2.to_solr[Solrizer.solr_name(:collection)]).to eq([])
      ## Check that member was re-indexed without collection info
      asset_results = blacklight_solr.get "select", params:{fq:["id:\"#{@asset2.pid}\""],fl:['id',Solrizer.solr_name(:collection)]}
      doc = asset_results["response"]["docs"].first
      expect(doc["id"]).to eq(@asset2.pid)
      expect(doc[Solrizer.solr_name(:collection)]).to be_nil
      solr_doc_after_remove = ActiveFedora::SolrInstanceLoader.new(ActiveFedora::Base, @asset2.pid).send(:solr_doc)
      expect(solr_doc_after_remove[Solrizer.solr_name(:collection)]).to be_nil
    end
    
    it "should allow moving members between collections" do
      @collection.members = [@asset1, @asset2, @asset3]
      @collection.save
      @collection2 = Collection.new
      @collection2.apply_depositor_metadata(@user.user_key)
      @collection2.save
      put :update, id: @collection.id, collection: {members:"move"}, destination_collection_id:@collection2.pid, batch_document_ids:[@asset2, @asset3]
      expect(::Collection.find(@collection.pid).members).to eq([@asset1])
      expect(::Collection.find(@collection2.pid).members).to eq([@asset2, @asset3])
    end

  end

  describe "#destroy" do
    describe "valid collection" do
      before do
        @collection = Collection.new
        @collection.apply_depositor_metadata(@user.user_key)
        @collection.save
        expect(controller).to receive(:authorize!).and_return(true)
      end
      it "should delete collection" do
        delete :destroy, id: @collection.id
        expect(response).to redirect_to Rails.application.routes.url_helpers.catalog_index_path
        expect(flash[:notice]).to eq("Collection was successfully deleted.")
      end
      it "should after_destroy" do
        expect(controller).to receive(:after_destroy).and_call_original
        delete :destroy, id: @collection.id
      end
      it "should call update members" do
        @asset1 = GenericFile.create!
        @collection.members << @asset1
        @collection.save
        @asset1 = @asset1.reload
        @asset1.update_index
        expect(@asset1.collections).to eq([@collection])
        asset_results = blacklight_solr.get "select", params:{fq:["id:\"#{@asset1.pid}\""],fl:['id',Solrizer.solr_name(:collection)]}
        expect(asset_results["response"]["numFound"]).to eq(1)
        doc = asset_results["response"]["docs"].first
        expect(doc[Solrizer.solr_name(:collection)]).to eq([@collection.pid])

        delete :destroy, id: @collection.id
        expect(@asset1.reload.collections).to eq([])
        asset_results = blacklight_solr.get "select", params:{fq:["id:\"#{@asset1.pid}\""],fl:['id',Solrizer.solr_name(:collection)]}
        expect(asset_results["response"]["numFound"]).to eq(1)
        doc = asset_results["response"]["docs"].first
        expect(doc[Solrizer.solr_name(:collection)]).to be_nil
        @asset1.destroy
      end
    end
    it "should not delete an invalid collection" do
       expect {delete :destroy, id: 'zz:-1'}.to raise_error
    end
  end

  describe "with a number of assets #show" do
    before do
      @asset1 = GenericFile.create!(title: "First of the Assets")
      @asset2 = GenericFile.create!(title: "Second of the Assets")
      @asset3 = GenericFile.create!(title: "Third of the Assets")
      @collection = Collection.new(pid:"abc:123")
      @collection.title = "My collection"
      @collection.apply_depositor_metadata(@user.user_key)
      @collection.members = [@asset1,@asset2,@asset3]
      @collection.save
      allow(controller).to receive(:authorize!).and_return(true)
      allow(controller).to receive(:apply_gated_search)
    end
    it "should show the collections" do
      get :show, id: @collection.id
      expect(assigns[:collection].title).to eq(@collection.title)
      ids = assigns[:member_docs].map {|d| d.id}
      expect(ids).to include @asset1.pid
      expect(ids).to include @asset2.pid
      expect(ids).to include @asset3.pid
    end
    context "when items have been added and removed" do
      it "should return the items that are in the collection and not return items that have been removed" do
        asset4 = GenericFile.create!(title: "Fourth of the Assets")
        put :update, id: @collection.id, collection: {members:"remove"}, batch_document_ids:[@asset2.pid]
        controller.batch = nil
        put :update, id: @collection.id, collection: {members:"add"}, batch_document_ids:[asset4.pid]
        get :show, id: @collection.id
        ids = assigns[:member_docs].map(&:id)
        expect(ids).to include @asset1.pid, @asset3.pid, asset4.pid
        expect(ids).to_not include @asset2.pid
      end
    end
    describe "additional collections" do
      before do
        @asset4 = GenericFile.create!(title: "#{@asset1.id}")
        @collection2 = Collection.new(pid:"abc:1234")
        @collection2.title = "Other collection"
        @collection2.apply_depositor_metadata(@user.user_key)
        @collection2.members = [@asset4]
        @collection2.save
        @asset4 = @asset4.reload
        expect(@asset4.collections).to eq([@collection2])
      end

      it "should show only the collections assets" do
        get :show, id: @collection.pid
        expect(assigns[:collection].title).to eq(@collection.title)
        ids = assigns[:member_docs].map {|d| d.id}
        expect(ids).to include @asset1.pid
        expect(ids).to include @asset2.pid
        expect(ids).to include @asset3.pid
        expect(ids).not_to include @asset4.pid

      end
      it "should show only the other collections assets" do

        get :show, id: @collection2.pid
        expect(assigns[:collection].title).to eq(@collection2.title)
        ids = assigns[:member_docs].map {|d| d.id}
        expect(ids).not_to include @asset1.pid
        expect(ids).not_to include @asset2.pid
        expect(ids).not_to include @asset3.pid
        expect(ids).to include @asset4.pid

      end
    end

    it "when the collection is empty it should show no assets" do
      get :show, id: Collection.create(title: "Empty collection").id
      expect(assigns[:collection].title).to eq("Empty collection")
      expect(assigns[:member_docs]).to be_empty
    end

    # NOTE: This test depends on title_tesim being in the qf in solrconfig.xml
    it "should query the collections" do
      get :show, id: @collection.id, cq:"\"#{@asset1.title}\""
      expect(assigns[:collection].title).to eq(@collection.title)
      ids = assigns[:member_docs].map {|d| d.id}
      expect(ids).to include @asset1.pid
      expect(ids).not_to include @asset2.pid
      expect(ids).not_to include @asset3.pid
    end

    # NOTE: This test depends on title_tesim being in the qf in solrconfig.xml
    it "should query the collections and show only the collection assets" do
      @asset4 = GenericFile.create!(title: "#{@asset1.id} #{@asset1.title}")
      @asset5 = GenericFile.create!(title: "#{@asset1.title}")
      get :show, id: @collection.id, cq:"\"#{@asset1.title}\""
      expect(assigns[:collection].title).to eq(@collection.title)
      ids = assigns[:member_docs].map {|d| d.id}
      expect(ids).to include @asset1.pid
      expect(ids).not_to include @asset2.pid
      expect(ids).not_to include @asset3.pid
      expect(ids).not_to include @asset4.pid
      expect(ids).not_to include @asset5.pid
    end

    it "should query the collections with rows" do
      get :show, id: @collection.id, rows:"2"
      expect(assigns[:collection].title).to eq(@collection.title)
      ids = assigns[:member_docs].map {|d| d.id}
      expect(ids.count).to eq(2)
    end

  end

end
