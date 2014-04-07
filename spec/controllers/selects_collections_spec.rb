require "spec_helper"

class SelectsCollectionsController < ApplicationController
  include Blacklight::Catalog
  include Hydra::Controller::ControllerBehavior
  include Hydra::Collections::SelectsCollections

  SelectsCollectionsController.solr_search_params_logic += [:add_access_controls_to_solr_params]

end


describe SelectsCollectionsController do

  describe "#find_collections" do
    it "should override solr_search_params_logic to use collection_search_params_logic, then switch it back" do
      # Looks like we can only test this indirectly b/c blacklight doesn't let you explicitly pass solr_search_params_logic when running searches -- you have to set the controller's solr_search_params_logic class attribute
      original_solr_logic = subject.solr_search_params_logic
      subject.collection_search_params_logic.should == [:default_solr_parameters, :add_query_to_solr, :add_access_controls_to_solr_params, :add_collection_filter]
      subject.class.should_receive(:solr_search_params_logic=).with(subject.collection_search_params_logic)
      subject.class.should_receive(:solr_search_params_logic=).with(original_solr_logic)
      subject.find_collections
    end
  end
  
  describe "Select Collections" do
    before (:all) do
      @user = FactoryGirl.find_or_create(:user)
      @collection = Collection.new title:"Test Public"
      @collection.apply_depositor_metadata(@user.user_key)
      @collection.read_groups = ["public"]
      @collection.save
      @collection2 = Collection.new title:"Test Read"
      @collection2.apply_depositor_metadata('abc123@test.com')
      @collection2.read_users = [@user.user_key]
      @collection2.save
      @collection3 = Collection.new title:"Test Edit"
      @collection3.apply_depositor_metadata('abc123@test.com')
      @collection3.edit_users = [@user.user_key]
      @collection3.save 
      @collection4 = Collection.new title:"Test No Access"
      @collection4.apply_depositor_metadata('abc123@test.com')
      @collection4.save
      @collections = []
      (1..11).each do |i|
        collection = Collection.new title:"Test Public #{i}"
        collection.apply_depositor_metadata(@user.user_key)
        collection.read_groups = ["public"]
        collection.save
        @collections << collection
      end
    end
    after (:all) do
      Collection.delete_all
    end
    describe "Public Access" do
      before (:each) do
        subject.find_collections
        @user_collections =  subject.instance_variable_get (:@user_collections)
        expect(@user_collections).to be_kind_of(Array)
      end
      it "should return public collections" do
        @user_collections.index{|d| d.id == @collection.id}.should_not be_nil
      end
      it "should return all public collections" do
        @user_collections.count.should == 12
      end
      it "should not return non public collections" do
        @user_collections.index{|d| d.id == @collection2.id}.should be_nil
        @user_collections.index{|d| d.id == @collection3.id}.should be_nil
        @user_collections.index{|d| d.id == @collection4.id}.should be_nil
       end
    end
    describe "Read Access" do
      describe "not signed in" do
        it "should error if the user is not signed in" do
          expect { subject.find_collections_with_read_access }.to raise_error
        end
      end
      describe "signed in" do
        before (:each) do
          sign_in @user
          subject.find_collections_with_read_access
          @user_collections =  subject.instance_variable_get (:@user_collections)
          expect(@user_collections).to be_kind_of(Array)
        end
        it "should return public and read access (edit access implies read) collections" do
          @user_collections.index{|d| d.id == @collection.id}.should_not be_nil
          @user_collections.index{|d| d.id == @collection2.id}.should_not be_nil
          @user_collections.index{|d| d.id == @collection3.id}.should_not be_nil
        end 
        it "should not return non public collections" do
          @user_collections.index{|d| d.id == @collection4.id}.should be_nil
        end
      end
    end
    describe "Edit Access" do
      describe "not signed in" do
        it "should error if the user is not signed in" do
          expect { subject.find_collections_with_edit_access }.to raise_error
        end
      end
      describe "signed in" do
        before (:each) do
          sign_in @user
          subject.find_collections_with_edit_access
           @user_collections =  subject.instance_variable_get (:@user_collections)
           expect(@user_collections).to be_kind_of(Array)
         end
        it "should return public or editable collections" do
          @user_collections.index{|d| d.id == @collection.id}.should_not be_nil
          @user_collections.index{|d| d.id == @collection3.id}.should_not be_nil
        end 
        it "should not return non public or editable collections" do
          @user_collections.index{|d| d.id == @collection2.id}.should be_nil
          @user_collections.index{|d| d.id == @collection4.id}.should be_nil
        end
      end
    end
  end
  
end
