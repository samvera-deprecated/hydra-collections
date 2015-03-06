require 'spec_helper'

# make sure a collection by another name still assigns the @collection variable
describe OtherCollectionsController, :type => :controller do
  before(:all) do
    class OtherCollection < ActiveFedora::Base
      include Hydra::Collection
      include Hydra::Collections::Collectible
    end

    class Member < ActiveFedora::Base
      include Hydra::Collections::Collectible
      attr_accessor :title
    end
  end

  after(:all) do
    Object.send(:remove_const, :Member)
    Object.send(:remove_const, :OtherCollection)
  end

  let(:user) { FactoryGirl.find_or_create(:user) }

  before do
    allow(controller).to receive(:has_access?).and_return(true)
    sign_in user
    # allow_any_instance_of(User).to receive(:groups).and_return([])
    # allow(controller).to receive(:clear_session_user) ## Don't clear out the authenticated session
  end

  describe "#show" do
    let(:asset1) { Member.create!(title: "First of the Assets") }
    let(:asset2) { Member.create!(title: "Second of the Assets") }
    let(:asset3) { Member.create!(title: "Third of the Assets") }
    let(:collection) do
      OtherCollection.create(id: 'foo123', title: "My collection",
                             members: [asset1, asset2, asset3]) do |collection|
        collection.apply_depositor_metadata(user.user_key)
      end
    end

    before do
      allow(controller).to receive(:apply_gated_search)
    end

    it "should show the collections" do
      get :show, id: collection
      expect(assigns[:collection].title).to eq collection.title
      ids = assigns[:member_docs].map(&:id)
      expect(ids).to include(asset1.id, asset2.id, asset3.id)
    end
  end
end
