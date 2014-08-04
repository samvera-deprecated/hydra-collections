require "spec_helper"

class AcceptsBatchesController < ApplicationController
  include Hydra::Collections::AcceptsBatches
end

describe AcceptsBatchesController, :type => :controller do

  describe "batch" do
    it "should accept batch from parameters" do
      controller.params["batch_document_ids"] = ["abc", "xyz"]
      expect(controller.batch).to eq(["abc", "xyz"])
    end
    describe ":all" do
      let(:current_user) { double(user_key: 'vanessa') }
      before do
        doc1 = double(:id=>123)
        doc2 = double(:id=>456)
        expect_any_instance_of(Hydra::Collections::SearchService).to receive(:last_search_documents).and_return([doc1, doc2])
        allow(controller).to receive(:current_user).and_return(current_user)
      end
      it "should add every document in the current resultset to the batch" do
        controller.params["batch_document_ids"] = "all"
        expect(controller.batch).to eq([123, 456])
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
      @allowed.each {|doc_id| expect(subject).to receive(:can?).with(:foo, doc_id).and_return(true)}
      @disallowed.each {|doc_id| expect(subject).to receive(:can?).with(:foo, doc_id).and_return(false)}
      subject.send(:filter_docs_with_access!, :foo)
      expect(flash[:notice]).to eq("You do not have permission to edit the documents: #{@disallowed.join(', ')}")
    end
    it "using filter_docs_with_edit_access!" do
      @allowed.each {|doc_id| expect(subject).to receive(:can?).with(:edit, doc_id).and_return(true)}
      @disallowed.each {|doc_id| expect(subject).to receive(:can?).with(:edit, doc_id).and_return(false)}
      subject.send(:filter_docs_with_edit_access!)
      expect(flash[:notice]).to eq("You do not have permission to edit the documents: #{@disallowed.join(', ')}")
    end
    it "using filter_docs_with_read_access!" do
      @allowed.each {|doc_id| expect(subject).to receive(:can?).with(:read, doc_id).and_return(true)}
      @disallowed.each {|doc_id| expect(subject).to receive(:can?).with(:read, doc_id).and_return(false)}
      subject.send(:filter_docs_with_read_access!)
      expect(flash[:notice]).to eq("You do not have permission to edit the documents: #{@disallowed.join(', ')}")
    end
    it "and be sassy if you didn't select anything" do
      subject.batch = []
      subject.send(:filter_docs_with_read_access!)
      expect(flash[:notice]).to eq("Select something first")
    end
    
  end
    
  it "should check for empty" do
    controller.batch = ["77826928", "94120425"]
    expect(controller.check_for_empty_batch?).to eq(false)
    controller.batch = []
    expect(controller.check_for_empty_batch?).to eq(true)
  end


  
end
