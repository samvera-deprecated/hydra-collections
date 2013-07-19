require 'spec_helper'

include Hydra::Collections::Engine.routes.url_helpers

describe CollectionsHelper do
  describe "button_for_create_collection" do
    it " should create a button to the collections new path" do
      str = String.new(helper.button_for_create_collection)
      doc = Nokogiri::HTML(str)
      form = doc.xpath('//form').first
      form.attr('action').should == "#{collections.new_collection_path}"
      i = form.children.first.children.first
      i.attr('type').should == 'submit'
    end
    it "should create a button with my text" do
      str = String.new(helper.button_for_create_collection "Create My Button")
      doc = Nokogiri::HTML(str)
      form = doc.xpath('//form').first
      form.attr('action').should == "#{collections.new_collection_path}"
      i = form.children.first.children.first
      i.attr('value').should == 'Create My Button'
    end
  end
  describe "button_for_delete_collection" do
    before (:all) do
      @collection = Collection.create(title: "Test Public")
    end
    after (:all) do
      @collection.delete
    end
    it " should create a button to the collections delete path" do
      str = button_for_delete_collection @collection
      doc = Nokogiri::HTML(str)
      form = doc.xpath('//form').first
      form.attr('action').should == "#{collections.collection_path(@collection.pid)}"
      i = form.children.first.children[1]
      i.attr('type').should == 'submit'
    end
    it "should create a button with my text" do
      str = button_for_delete_collection @collection, "Delete My Button"
      doc = Nokogiri::HTML(str)
      form = doc.xpath('//form').first
      form.attr('action').should == "#{collections.collection_path(@collection.pid)}"
      i = form.children.first.children[1]
      i.attr('value').should == "Delete My Button"
    end
  end
  describe "button_for_remove_from_collection" do
    let(:item) { double(id: 'changeme:123') } 
    before do
      @collection = Collection.create
    end

    it "should generate a form that can remove the item" do
      str = button_for_remove_from_collection item
      doc = Nokogiri::HTML(str)
      form = doc.xpath('//form').first
      form.attr('action').should == "#{collections.collection_path(@collection.pid)}"
      form.css('input#collection_members[type="hidden"][value="remove"]').should_not be_empty
      form.css('input[type="hidden"][name="batch_document_ids[]"][value="changeme:123"]').should_not be_empty
    end
  end 
  describe "button_for_remove_selected_from_collection" do
    before (:all) do
      @collection = Collection.create title:"Test Public"
    end
    after (:all) do
      @collection.delete
    end
    it " should create a button to the collections delete path" do
      str = button_for_remove_selected_from_collection @collection
      doc = Nokogiri::HTML(str)
      form = doc.xpath('//form').first
      form.attr('action').should == "#{collections.collection_path(@collection.pid)}"
      i = form.children[2]
      i.attr('value').should == "remove"
      i.attr('name').should == "collection[members]"
    end
    it "should create a button with my text" do
      str = button_for_remove_selected_from_collection @collection, "Remove My Button"
      doc = Nokogiri::HTML(str)
      form = doc.xpath('//form').first
      form.attr('action').should == "#{collections.collection_path(@collection.pid)}"
      i = form.children[3]
      i.attr('value').should == "Remove My Button"
    end
  end

  describe "hidden_collection_members" do
    before { helper.params[:batch_document_ids] = ['foo:12', 'foo:23'] }
    it "should make hidden fields" do
      doc = Nokogiri::HTML(hidden_collection_members)
      inputs = doc.xpath('//input[@type="hidden"][@name="batch_document_ids[]"]')
      inputs.length.should == 2
      inputs[0].attr('value').should == 'foo:12'
      inputs[1].attr('value').should == 'foo:23'
    end
  end

end
