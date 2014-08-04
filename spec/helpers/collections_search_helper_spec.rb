require 'spec_helper'

describe CollectionsSearchHelper, :type => :helper do
  describe "collection_name" do
    let (:collection_without_title) { Collection.create() }
    let (:collection_with_title) { Collection.create(title: "Title of Collection 2") }
    it "should return the pid if no title available" do
      expect(collection_name(collection_without_title.pid)).to eq(collection_without_title.pid)
    end
    it "should return the title value associated with the given pid" do
      expect(collection_name(collection_with_title.pid)).to eq("Title of Collection 2")
    end
  end
end
