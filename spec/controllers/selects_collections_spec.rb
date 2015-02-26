require "spec_helper"

class SelectsCollectionsController < ApplicationController
  include Blacklight::Catalog
  include Hydra::Controller::ControllerBehavior
  include Hydra::Collections::SelectsCollections

  SelectsCollectionsController.search_params_logic += [:add_access_controls_to_solr_params]

end


describe SelectsCollectionsController, :type => :controller do

  describe "#find_collections" do
    it "should use collection_search_params_logic" do
      expect(subject.collection_search_params_logic).to eq([:default_solr_parameters, :add_query_to_solr, :add_access_controls_to_solr_params, :add_collection_filter, :some_rows])
      expect(subject).to receive(:search_results).with({ q: '' }, subject.collection_search_params_logic)
      subject.find_collections
    end
  end

  describe "Select Collections" do
    before do
      @user = FactoryGirl.find_or_create(:user)
      @collection = Collection.new title:"Test Public"
      @collection.apply_depositor_metadata(@user.user_key)
      @collection.read_groups = ["public"]
      @collection.save
      @collection2 = Collection.new title:"Test Read"
      @collection2.apply_depositor_metadata('abc123@test.com')
      @collection2.read_users = [@user.user_key]
      @collection2.save
      @collection3 = Collection.new title:"Test Edit"
      @collection3.apply_depositor_metadata('abc123@test.com')
      @collection3.edit_users = [@user.user_key]
      @collection3.save 
      @collection4 = Collection.new title:"Test No Access"
      @collection4.apply_depositor_metadata('abc123@test.com')
      @collection4.save
    end

    describe "Public Access" do
      let(:user_collections) do
        subject.find_collections
        subject.instance_variable_get(:@user_collections)
      end

      it "should only return public collections" do
        expect(user_collections.map(&:id)).to match_array [@collection.id]
      end

      context "when there are more than 10" do
        before do
          11.times do |i|
            Collection.new(title:"Test Public #{i}").tap do |col|
              col.apply_depositor_metadata(@user.user_key)
              col.read_groups = ["public"]
              col.save!
            end
          end
        end
        it "should return all public collections" do
          expect(user_collections.count).to eq(12)
        end
      end
    end

    describe "Read Access" do
      describe "not signed in" do
        it "should error if the user is not signed in" do
          expect { subject.find_collections_with_read_access }.to raise_error
        end
      end
      describe "signed in" do
        before { sign_in @user }

        let(:user_collections) do
          subject.find_collections_with_read_access
          subject.instance_variable_get(:@user_collections)
        end

        it "should return only public and read access (edit access implies read) collections" do
          expect(user_collections.map(&:id)).to match_array [@collection.id, @collection2.id, @collection3.id]
        end 
      end
    end

    describe "Edit Access" do
      describe "not signed in" do
        it "should error if the user is not signed in" do
          expect { subject.find_collections_with_edit_access }.to raise_error
        end
      end

      describe "signed in" do
        before { sign_in @user }

        let(:user_collections) do
          subject.find_collections_with_edit_access
          subject.instance_variable_get(:@user_collections)
        end

        it "should return only public or editable collections" do
          expect(user_collections.map(&:id)).to match_array [@collection.id, @collection3.id]
        end 
      end
    end
  end
end
