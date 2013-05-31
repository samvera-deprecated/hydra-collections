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
      html = button_for_create_collection 
      html.should have_selector("form[action='#{collections.new_collection_path}']")
      html.should have_selector("input[type='submit']")
    end
    it "should create a button with my text" do
      html = button_for_create_collection "Create My Button"
      html.should have_selector("input[value='Create My Button']")
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
    html = button_for_delete_collection @collection
    html.should have_selector("form[action='#{collections.collection_path(@collection.pid)}']")
    html.should have_selector("input[type='submit']")
  end
  it "should create a button with my text" do
    html = button_for_delete_collection @collection,  "Delete My Button"
    html.should have_selector("input[value='Delete My Button']")
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
      html = button_for_remove_selected_from_collection @collection
      html.should have_selector("form[action='#{collections.collection_path(@collection.pid)}']")
      html.should have_selector("input[type='submit']")
    end
    it "should create a button with my text" do
      html = button_for_remove_selected_from_collection @collection, "Remove My Button"
      html.should have_selector("input[value='Remove My Button']")
    end
  end

end
