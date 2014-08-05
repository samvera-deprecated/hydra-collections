require 'spec_helper'

describe Collection, :type => :model do
  before(:all) do
    @user = FactoryGirl.find_or_create(:user)
    class GenericFile < ActiveFedora::Base
      include Hydra::Collections::Collectible

      def to_solr(solr_doc={}, opts={})
        super(solr_doc, opts)
        solr_doc = index_collection_pids(solr_doc)
        return solr_doc
      end

    end
  end
  after(:all) do
    @user.destroy
    Object.send(:remove_const, :GenericFile)
  end
  before(:each) do
    @collection = Collection.new
    @collection.apply_depositor_metadata(@user.user_key)
    @collection.save
    @gf1 = GenericFile.create
    @gf2 = GenericFile.create
  end
  after(:each) do
    @collection.destroy rescue
    @gf1.destroy
    @gf2.destroy
  end
  it "should have a depositor" do
    expect(@collection.depositor).to eq(@user.user_key)
  end
  it "should allow the depositor to edit and read" do
    ability = Ability.new(@user)
    expect(ability.can?(:read, @collection)).to  eq(true)
    expect(ability.can?(:edit, @collection)).to  eq(true)
  end
  it "should be empty by default" do
    expect(@collection.members).to be_empty
  end
  it "should have many files" do
    @collection.members = [@gf1, @gf2]
    @collection.save
    expect(Collection.find(@collection.pid).members).to eq([@gf1, @gf2])
  end
  it "should allow new files to be added" do
    @collection.members = [@gf1]
    @collection.save
    @collection = Collection.find(@collection.pid)
    @collection.members << @gf2
    @collection.save
    expect(Collection.find(@collection.pid).members).to eq([@gf1, @gf2])
  end
  it "should allow files to be removed" do
    @collection.members = [@gf1, @gf2]
    @collection.save

    expect(@gf1.collections).to eq [@collection] # This line forces the "collections" to be cached.
    # We need to ensure that deleting causes the collection to be flushed.
    solr_doc_before_remove = ActiveFedora::SolrInstanceLoader.new(ActiveFedora::Base, @gf1.pid).send(:solr_doc)
    expect(solr_doc_before_remove["collection_tesim"]).to eq([@collection.pid])
    @collection.reload.members.delete(@gf1)
    @collection.save
    expect(Collection.find(@collection.pid).members).to eq([@gf2])
    solr_doc_after_remove = ActiveFedora::SolrInstanceLoader.new(ActiveFedora::Base, @gf1.pid).send(:solr_doc)
    expect(solr_doc_after_remove["collection_tesim"]).to be_nil
  end
  it "should set the date uploaded on create" do
    @collection.save
    expect(@collection.date_uploaded).to be_kind_of(Date)
  end
  it "should update the date modified on update" do
    uploaded_date = Date.today
    modified_date = Date.tomorrow
    allow(Date).to receive(:today).and_return(uploaded_date, modified_date)
    @collection.save
    expect(@collection.date_modified).to eq(uploaded_date)
    @collection.members = [@gf1]
    @collection.save
    expect(@collection.date_modified).to eq(modified_date)
    @gf1 = @gf1.reload
    expect(@gf1.collections).to include(@collection)
    expect(@gf1.to_solr[Solrizer.solr_name(:collection)]).to eq([@collection.id])
  end
  it "should have a title" do
    @collection.title = "title"
    @collection.save
    expect(Collection.find(@collection.pid).title).to eq(@collection.title)
  end
  it "should have a description" do
    @collection.description = "description"
    @collection.save
    expect(Collection.find(@collection.pid).description).to eq(@collection.description)
  end
  it "should have the expected display terms" do
    expect(@collection.terms_for_display).to eq([:part_of, :contributor, :creator, :title, :description, :publisher, :date_created, :date_uploaded, :date_modified, :subject, :language, :rights, :resource_type, :identifier, :based_near, :tag, :related_url])
  end
  it "should have the expected edit terms" do
    expect(@collection.terms_for_editing).to eq([:part_of, :contributor, :creator, :title, :description, :publisher, :date_created, :subject, :language, :rights, :resource_type, :identifier, :based_near, :tag, :related_url])
  end
  it "should not delete member files when deleted" do
    @collection.members = [@gf1, @gf2]
    @collection.save
    @collection.destroy
    expect(GenericFile.exists?(@gf1.pid)).to be_truthy
    expect(GenericFile.exists?(@gf2.pid)).to be_truthy
  end

  describe "Collection by another name" do
    before (:all) do
      class OtherCollection < ActiveFedora::Base
        include Hydra::Collection
        include Hydra::Collections::Collectible
      end
      class Member < ActiveFedora::Base
        include Hydra::Collections::Collectible
      end
    end
    after(:all) do
      Object.send(:remove_const, :OtherCollection)
      Object.send(:remove_const, :Member)
    end

    it "have members that know about the collection" do
      collection = OtherCollection.new
      member = Member.create
      collection.members << member
      collection.save
      member.reload
      expect(member.collections).to eq([collection])
      collection.destroy
      member.destroy
    end
  end

end
