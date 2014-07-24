require 'spec_helper'

include Rails.application.routes.url_helpers

describe CatalogController, :type => :controller do

  before do
    allow(controller).to receive(:has_access?).and_return(true)
    @user = FactoryGirl.find_or_create(:user)
    @collection = Collection.new title: "Test"
    @collection.apply_depositor_metadata(@user.user_key)
    @collection.read_groups = ["public"]
    @collection.save!
  end

  after do
    @collection.destroy
  end
  
  routes { Rails.application.routes }
  
  describe '#index' do
    it 'should assign @user_collections' do
      get :index
      expect(assigns(:user_collections)).to be_kind_of(Array)
      expect(assigns(:user_collections).index{|d| d.id == @collection.id}).not_to be_nil
    end
  end
  
end
