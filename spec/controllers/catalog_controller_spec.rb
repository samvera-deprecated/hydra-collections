# Copyright © 2012 The Pennsylvania State University
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

include Rails.application.routes.url_helpers

describe CatalogController do
  before do
    controller.stub(:has_access?).and_return(true)
    @user = FactoryGirl.find_or_create(:user)
    @collection = Collection.new title:"Test"
    @collection.apply_depositor_metadata(@user.user_key)
    @collection.read_groups = ["public"]
    @collection.save
  end

  after do
    @user.delete
    @collection.delete
  end
  
  
  describe '#index' do
    it 'should assign @user_collections' do
      @routes = Rails.application.routes
      get :index
      expect(assigns(:user_collections)).to be_kind_of(Array)
      assigns(:user_collections).index{|d| d.id == @collection.id}.should_not be_nil
    end
  end
  
end
