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
      reloaded = CollectibleThing.find(@collectible.pid)
      @collection2.members.should == [@collectible]
      reloaded.collections.should == [@collection1, @collection2]
    end
  end
  describe "index_collection_pids" do
    it "should add pids for all associated collections" do
      @collectible.save
      @collectible.collections << @collection1
      @collectible.collections << @collection2
      @collectible.index_collection_pids["collection_sim"].should == [@collection1.pid, @collection2.pid]
    end
  end
end