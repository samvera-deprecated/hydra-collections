require "spec_helper"

class AcceptsBatchesController < ApplicationController
  include Hydra::Collections::AcceptsBatches
end

describe AcceptsBatchesController do

  describe "batch" do
    it "should accept batch from parameters" do
      controller.params["batch_document_ids"] = ["abc", "xyz"]
      controller.batch.should == ["abc", "xyz"]
    end
    describe ":all" do
      before do
        doc1 = stub(:id=>123)
        doc2 = stub(:id=>456)
        Hydra::Collections::SearchService.any_instance.should_receive(:last_search_documents).and_return([doc1, doc2])
        controller.stub(:current_user=>stub(:user_key=>'vanessa'))
      end
      it "should add every document in the current resultset to the batch" do
        controller.params["batch_document_ids"] = "all"
        controller.batch.should == [123, 456]
      end
    end
  end
  
  it "should filter_for_access" 
    
  it "should check for empty" do
    controller.batch = ["77826928", "94120425"]
    controller.check_for_empty_batch?.should == false
    controller.batch = []
    controller.check_for_empty_batch?.should == true
  end


  
end