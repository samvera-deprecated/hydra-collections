require "spec_helper"
class CollectibleThing < ActiveFedora::Base
  include Hydra::Collections::Collectible
end

describe Hydra::Collections::Collectible do
  before do
    @collection1 = FactoryGirl.create(:collection)
    @collection2 = FactoryGirl.create(:collection)
    @collectible = CollectibleThing.new
  end
  describe "collections associations" do
    it "should allow adding and removing" do
      @collectible.save
      @collection1.members << @collectible
      @collection1.save
      @collectible.collections << @collection2
      reloaded = CollectibleThing.find(@collectible.id)
      expect(@collection2.reload.members).to eq [@collectible]
      expect(reloaded.collections).to eq [@collection1, @collection2]
    end
  end
  describe "index_collection_ids" do
    it "should add ids for all associated collections" do
      @collectible.save
      @collectible.collections << @collection1
      @collectible.collections << @collection2
      expect(@collectible.index_collection_ids["collection_sim"]).to eq [@collection1.id, @collection2.id]
    end
  end
end
