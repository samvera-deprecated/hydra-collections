require 'spec_helper'

describe CollectionsSearchHelper do
  describe "collection_name" do
    let (:collection_without_title) { Collection.create() }
    let (:collection_with_title) { Collection.create(title: "Title of Collection 2") }
    it "should return the pid if no title available" do
      collection_name(collection_without_title.pid).should == collection_without_title.pid
    end
    it "should return the title value associated with the given pid" do
      collection_name(collection_with_title.pid).should == "Title of Collection 2"
    end
  end
end
