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
    class GenericFile < ActiveFedora::Base
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
    @collection.depositor.should == @user.user_key
  end
  it "should allow the depositor to edit and read" do
    ability = Ability.new(@user)
    ability.can?(:read, @collection).should  == true
    ability.can?(:edit, @collection).should  == true
  end
  it "should be empty by default" do
    @collection.members.should be_empty
  end
  it "should have many files" do
    @collection.members = [@gf1, @gf2]
    @collection.save
    Collection.find(@collection.pid).members.should == [@gf1, @gf2]
  end
  it "should allow new files to be added" do
    @collection.members = [@gf1]
    @collection.save
    @collection = Collection.find(@collection.pid)
    @collection.members << @gf2
    @collection.save
    Collection.find(@collection.pid).members.should == [@gf1, @gf2]
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
    @collection.members = [@gf1]
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
    @collection.terms_for_display.should == [:part_of, :contributor, :creator, :title, :description, :publisher, :date_created, :date_uploaded, :date_modified, :subject, :language, :rights, :resource_type, :identifier, :based_near, :tag, :related_url]
  end
  it "should have the expected edit terms" do
    @collection.terms_for_editing.should == [:part_of, :contributor, :creator, :title, :description, :publisher, :date_created, :subject, :language, :rights, :resource_type, :identifier, :based_near, :tag, :related_url]
  end
  it "should not delete member files when deleted" do
    @collection.members = [@gf1, @gf2]
    @collection.save
    @collection.destroy
    GenericFile.exists?(@gf1.pid).should be_true
    GenericFile.exists?(@gf2.pid).should be_true
  end
end
