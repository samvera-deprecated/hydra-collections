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

describe Collection do
  before(:all) do
    @user = FactoryGirl.find_or_create(:user)
  end
  after(:all) do
    @user.destroy
  end
  before(:each) do
    @collection = Collection.new
    @collection.apply_depositor_metadata(@user.user_key)
    @collection.save
    @gf1 = GenericFile.new
    @gf1.apply_depositor_metadata(@user.user_key)
    @gf1.save
    @gf2 = GenericFile.new
    @gf2.apply_depositor_metadata(@user.user_key)
    @gf2.save
  end
  after(:each) do
    @collection.destroy rescue
    @gf1.destroy
    @gf2.destroy
  end
  it "should have a depositor" do
    @collection.depositor.should == @user.user_key
  end
  it "should be empty by default" do
    @collection.generic_files.should be_empty
  end
  it "should have many files" do
    @collection.generic_files = [@gf1, @gf2]
    @collection.save
    Collection.find(@collection.pid).generic_files.should == [@gf1, @gf2]
  end
  it "should allow new files to be added" do
    @collection.generic_files = [@gf1]
    @collection.save
    @collection = Collection.find(@collection.pid)
    @collection.generic_files << @gf2
    @collection.save
    Collection.find(@collection.pid).generic_files.should == [@gf1, @gf2]
  end
  it "should include the noid in solr" do
    @collection.save
    @collection.to_solr['noid_s'].should == @collection.noid
  end
  it "should set the date uploaded on create" do
    @collection.save
    @collection.date_uploaded.should be_kind_of(Date)
  end
  it "should update the date modified on update" do
    uploaded_date = Date.today
    modified_date = Date.tomorrow
    Date.stub(:today).and_return(uploaded_date, modified_date)
    @collection.save
    @collection.date_modified.should == uploaded_date
    @collection.generic_files = [@gf1]
    @collection.save
    @collection.date_modified.should == modified_date
  end
  it "should have a title" do
    @collection.title = "title"
    @collection.save
    Collection.find(@collection.pid).title.should == @collection.title
  end
  it "should have a description" do
    @collection.description = "description"
    @collection.save
    Collection.find(@collection.pid).description.should == @collection.description
  end
  it "should have the expected display terms" do
    @collection.terms_for_display.should == [:title, :description, :date_uploaded, :date_modified]
  end
  it "should have the expected edit terms" do
    @collection.terms_for_editing.should == [:title,:description]
  end
  it "should not delete member files when deleted" do
    @collection.generic_files = [@gf1, @gf2]
    @collection.save
    @collection.destroy
    lambda {GenericFile.find(@gf1.pid)}.should_not raise_error ActiveFedora::ObjectNotFoundError
    lambda {GenericFile.find(@gf2.pid)}.should_not raise_error ActiveFedora::ObjectNotFoundError
  end
end
