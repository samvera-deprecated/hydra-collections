require 'spec_helper'

describe CatalogController, :type => :controller do
  before do
    allow(controller).to receive(:has_access?).and_return(true)
  end

  let(:user) { FactoryGirl.create(:user) }
  let!(:collection) { FactoryGirl.create(:collection, user: user, read_groups: ['public']) }

  routes { Rails.application.routes }

  describe '#index' do
    it 'assigns @user_collections' do
      get :index
      expect(assigns(:user_collections)).to be_kind_of(Array)
      expect(assigns(:user_collections).map(&:id)).to include collection.id
    end
  end
end
