require "spec_helper"

describe Hydra::Collections::Collectible do
  before do
    class CollectibleThing < ActiveFedora::Base
      include Hydra::Collections::Collectible
    end
  end

  let(:collection1) { FactoryGirl.create(:collection) }
  let(:collection2) { FactoryGirl.create(:collection) }
  let(:collectible) { CollectibleThing.new }

  after do
    Object.send(:remove_const, :CollectibleThing)
  end

  describe "collections associations" do
    it "should allow adding and removing" do
      collectible.save
      collection1.members << collectible
      collection1.save
      collectible.collections << collection2
      reloaded = CollectibleThing.find(collectible.id)
      expect(collection2.reload.members).to eq [collectible]
      expect(reloaded.collections).to eq [collection1, collection2]
    end
  end

  describe "index_collection_ids" do
    it "should add ids for all associated collections" do
      collectible.save
      collectible.collections << collection1
      collectible.collections << collection2
      expect(Deprecation).to receive(:warn)
      expect(collectible.index_collection_ids["collection_sim"]).to eq [collection1.id, collection2.id]
    end
  end
end
