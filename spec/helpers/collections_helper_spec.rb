require 'spec_helper'

include Hydra::Collections::Engine.routes.url_helpers

describe CollectionsHelper, :type => :helper do
  describe "button_for_create_collection" do
    it " should create a button to the collections new path" do
      str = String.new(helper.button_for_create_collection)
      doc = Nokogiri::HTML(str)
      form = doc.xpath('//form').first
      expect(form.attr('action')).to eq("#{collections.new_collection_path}")
      i = form.xpath('.//input').first
      expect(i.attr('type')).to eq('submit')
    end
    it "should create a button with my text" do
      str = String.new(helper.button_for_create_collection "Create My Button")
      doc = Nokogiri::HTML(str)
      form = doc.xpath('//form').first
      expect(form.attr('action')).to eq("#{collections.new_collection_path}")
      i = form.xpath('.//input').first
      expect(i.attr('value')).to eq('Create My Button')
    end
  end
  describe "button_for_delete_collection" do
    before do
      @collection = Collection.create(title: "Test Public")
    end

    it " should create a button to the collections delete path" do
      str = button_for_delete_collection @collection
      doc = Nokogiri::HTML(str)
      form = doc.xpath('//form').first
      expect(form.attr('action')).to eq collections.collection_path(@collection)
      i = form.xpath('.//input')[1]
      expect(i.attr('type')).to eq('submit')
    end
    it "should create a button with my text" do
      str = button_for_delete_collection @collection, "Delete My Button"
      doc = Nokogiri::HTML(str)
      form = doc.xpath('//form').first
      expect(form.attr('action')).to eq collections.collection_path(@collection)
      i = form.xpath('.//input')[1]
      expect(i.attr('value')).to eq("Delete My Button")
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
      expect(form.attr('action')).to eq collections.collection_path(@collection)
      expect(form.css('input#collection_members[type="hidden"][value="remove"]')).not_to be_empty
      expect(form.css('input[type="hidden"][name="batch_document_ids[]"][value="changeme:123"]')).not_to be_empty
    end

    describe "for a collection of another name" do
      before(:all) do
        class OtherCollection < ActiveFedora::Base
          include Hydra::Collection
          include Hydra::Works::WorkBehavior
        end

        @collection = OtherCollection.create
      end
      after(:all) do
        Object.send(:remove_const, :OtherCollection)
      end

      it "should generate a form that can remove the item" do
        str = button_for_remove_from_collection item
        doc = Nokogiri::HTML(str)
        form = doc.xpath('//form').first
        expect(form.attr('action')).to eq collections.collection_path(@collection)
        expect(form.css('input#collection_members[type="hidden"][value="remove"]')).not_to be_empty
        expect(form.css('input[type="hidden"][name="batch_document_ids[]"][value="changeme:123"]')).not_to be_empty
      end

    end
  end

  describe "button_for_remove_selected_from_collection" do
    before do
      @collection = Collection.create title: "Test Public"
    end

    it " should create a button to the collections delete path" do
      str = button_for_remove_selected_from_collection @collection
      doc = Nokogiri::HTML(str)
      form = doc.xpath('//form').first
      expect(form.attr('action')).to eq collections.collection_path(@collection)
      i = form.xpath('.//input')[2]
      expect(i.attr('value')).to eq("remove")
      expect(i.attr('name')).to eq("collection[members]")
    end

    it "should create a button with my text" do
      str = button_for_remove_selected_from_collection @collection, "Remove My Button"
      doc = Nokogiri::HTML(str)
      form = doc.css('form').first
      expect(form.attr('action')).to eq collections.collection_path(@collection)
      expect(form.css('input[type="submit"]').attr('value').value).to eq "Remove My Button"
    end
  end

  describe "hidden_collection_members" do
    before { helper.params[:batch_document_ids] = ['foo:12', 'foo:23'] }
    it "should make hidden fields" do
      doc = Nokogiri::HTML(hidden_collection_members)
      inputs = doc.xpath('//input[@type="hidden"][@name="batch_document_ids[]"]')
      expect(inputs.length).to eq(2)
      expect(inputs[0].attr('value')).to eq('foo:12')
      expect(inputs[1].attr('value')).to eq('foo:23')
    end
  end

end
