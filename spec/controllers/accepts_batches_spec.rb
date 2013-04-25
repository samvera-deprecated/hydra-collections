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
  
  describe "should allow filtering for access" do
    before do
      @allowed = [1,2,3]
      @disallowed = [5,6,7]
      subject.batch = @allowed + @disallowed
    end
    it "using filter_docs_with_access!" do
      @allowed.each {|doc_id| subject.should_receive(:can?).with(:foo, doc_id).and_return(true)}
      @disallowed.each {|doc_id| subject.should_receive(:can?).with(:foo, doc_id).and_return(false)}
      subject.send(:filter_docs_with_access!, :foo)
      subject.batch.should
      flash[:notice].should == "You do not have permission to edit the documents: #{@disallowed.join(', ')}"
    end
    it "using filter_docs_with_edit_access!" do
      @allowed.each {|doc_id| subject.should_receive(:can?).with(:edit, doc_id).and_return(true)}
      @disallowed.each {|doc_id| subject.should_receive(:can?).with(:edit, doc_id).and_return(false)}
      subject.send(:filter_docs_with_edit_access!)
      subject.batch.should
      flash[:notice].should == "You do not have permission to edit the documents: #{@disallowed.join(', ')}"
    end
    it "using filter_docs_with_read_access!" do
      @allowed.each {|doc_id| subject.should_receive(:can?).with(:read, doc_id).and_return(true)}
      @disallowed.each {|doc_id| subject.should_receive(:can?).with(:read, doc_id).and_return(false)}
      subject.send(:filter_docs_with_read_access!)
      subject.batch.should
      flash[:notice].should == "You do not have permission to edit the documents: #{@disallowed.join(', ')}"
    end
    it "and be sassy if you didn't select anything" do
      subject.batch = []
      subject.send(:filter_docs_with_read_access!)
      flash[:notice].should == "Select something first"
    end
    
  end
    
  it "should check for empty" do
    controller.batch = ["77826928", "94120425"]
    controller.check_for_empty_batch?.should == false
    controller.batch = []
    controller.check_for_empty_batch?.should == true
  end


  
end