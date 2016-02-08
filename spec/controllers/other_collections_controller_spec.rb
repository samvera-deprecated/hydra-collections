require 'spec_helper'

# make sure a collection by another name still assigns the @collection variable
describe OtherCollectionsController, :type => :controller do
  before(:all) do
    class OtherCollection < ActiveFedora::Base
      include Hydra::Collection
    end

    class Member < ActiveFedora::Base
      include Hydra::Works::WorkBehavior
      include Hydra::AccessControls::Permissions
    end
  end

  after(:all) do
    Object.send(:remove_const, :Member)
    Object.send(:remove_const, :OtherCollection)
  end

  let(:user) { FactoryGirl.create(:user) }

  before do
    allow(controller).to receive(:has_access?).and_return(true)
    sign_in user
  end

  describe "#show" do
    let(:asset1) { Member.create!(read_users: [user.user_key]) }
    let(:asset2) { Member.create!(read_users: [user.user_key]) }
    let(:asset3) { Member.create!(read_users: [user.user_key]) }
    let(:collection) do
      OtherCollection.create(id: 'foo123', title: ["My collection"],
                             members: [asset1, asset2, asset3]) do |collection|
        collection.apply_depositor_metadata(user.user_key)
      end
    end

    before do
      allow(controller).to receive(:apply_gated_search)
    end

    it "shows the collections" do
      get :show, id: collection
      expect(assigns[:collection].title).to eq collection.title
      ids = assigns[:member_docs].map(&:id)
      expect(ids).to include(asset1.id, asset2.id, asset3.id)
    end
  end
end
