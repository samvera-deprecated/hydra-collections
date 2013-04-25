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
  it "button_for_create_collection should create a button to the collections new path" do
    html = button_for_create_collection 
    html.should have_selector("form[action='#{collections.new_collection_path}']")
    html.should have_selector("input[type='submit']")
  end
  it "button_for_create_collection should create a button with my text" do
    html = button_for_create_collection "Create My Button"
    html.should have_selector("input[value='Create My Button']")
  end
end
