require "spec_helper"

describe Hydra::Collections::Collectible do
  before do
    class CollectibleThing < ActiveFedora::Base
      include Hydra::Collections::Collectible
    end
  end

  let(:collection1) { FactoryGirl.build(:collection) }
  let(:collection2) { FactoryGirl.create(:collection) }
  let(:collectible) { CollectibleThing.create }

  after do
    Object.send(:remove_const, :CollectibleThing)
  end

  describe "collections associations" do
    before do
      collection1.members << collectible
      collection1.save
      collection2.members << collectible
      collection2.save
    end

    it "queries the members" do
      expect(collectible.reload.collections).to eq [collection1, collection2]
    end

    it "counts the members" do
      expect(collectible.reload.collections.size).to eq 2
    end

    it "queries the ids" do
      expect(collectible.reload.collection_ids).to eq [collection1.id, collection2.id]
    end
  end
end
