require 'spec_helper'

describe CollectionsSearchHelper, :type => :helper do
  describe "collection_name" do
    let(:collection_without_title) { FactoryGirl.create(:collection) }
    let(:collection_with_title) { FactoryGirl.create(:collection, title: ["Title of Collection 2"]) }

    it "returns the id if no title available" do
      expect(collection_name(collection_without_title.id)).to eq collection_without_title.id
    end

    it "returns the title value associated with the given pid" do
      expect(collection_name(collection_with_title.id)).to eq "Title of Collection 2"
    end
  end
end
