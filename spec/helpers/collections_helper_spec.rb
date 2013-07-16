# Copyright © 2013 The Pennsylvania State University
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

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
    @collection = Collection.create title:"Test Public"
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

end
