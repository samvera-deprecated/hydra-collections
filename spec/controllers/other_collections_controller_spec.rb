require 'spec_helper'

class OtherCollectionsController < ApplicationController
  include Hydra::CollectionsControllerBehavior

  def show
    super
    redirect_to root_path
  end

end

class OtherCollection < ActiveFedora::Base
  include Hydra::Collection
  include Hydra::Collections::Collectible

  def to_solr(solr_doc={})
    super
    index_collection_ids(solr_doc)
  end
end

class Member < ActiveFedora::Base
  include Hydra::Collections::Collectible
  attr_accessor :title

  def to_solr(solr_doc={})
    super
    index_collection_ids(solr_doc)
  end

end

# make sure a collection by another name still assigns the @collection variable
describe OtherCollectionsController, :type => :controller do
  before(:all) do
    @user = FactoryGirl.find_or_create(:user)
  end
  after(:all) do
    @user.destroy
    Member.destroy_all
    OtherCollection.destroy_all
    Object.send(:remove_const, :Member)
    Object.send(:remove_const, :OtherCollection)
    Object.send(:remove_const, :OtherCollectionsController)

  end
  
  before do
    allow(controller).to receive(:has_access?).and_return(true)

    @user = FactoryGirl.find_or_create(:user)
    sign_in @user
    allow_any_instance_of(User).to receive(:groups).and_return([])
    allow(controller).to receive(:clear_session_user) ## Don't clear out the authenticated session
  end

  describe "#show" do
    let(:asset1) {Member.create!(title: "First of the Assets")}
    let(:asset2) {Member.create!(title: "Second of the Assets")}
    let(:asset3) {Member.create!(title: "Third of the Assets")}
    let(:collection) {OtherCollection.new}

    before do
      collection.title = "My collection"
      collection.apply_depositor_metadata(@user.user_key)
      collection.members = [asset1,asset2,asset3]
      collection.save
      allow(controller).to receive(:apply_gated_search)
    end
    after do
      Rails.application.reload_routes!
    end
    it "should show the collections" do
      routes.draw { resources :other_collections, except: :index }
      get :show, id: collection
      expect(assigns[:collection].title).to eq collection.title
      ids = assigns[:member_docs].map(&:id)
      expect(ids).to include(asset1.id, asset2.id, asset3.id)
    end
  end

end
