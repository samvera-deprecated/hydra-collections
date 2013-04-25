require 'spec_helper'

describe Hydra::Collections::SearchService do
  before do
    @login = 'vanessa'
    @session = {:history => [17, 14, 12, 9]}
    @service = Hydra::Collections::SearchService.new(@session, @login)
  end

  it "should get the documents for the first history entry" do
    Search.should_receive(:find).with(17).and_return(Search.new(:query_params=>{:q=>"World Peace"}))
    @service.should_receive(:get_search_results).and_return([:one, [:doc1, :doc2]])
    @service.last_search_documents.should == [:doc1, :doc2]
  end

  describe 'apply_gated_search' do
    before(:each) do
      RoleMapper.stub(:roles).with(@login).and_return(['umg/test.group.1'])
      params = @service.apply_gated_search({}, {})
      @group_query = params[:fq].first.split(' OR ')[1]
    end
    it "should escape slashes in groups" do
      @group_query.should == 'edit_access_group_ssim:umg\/test.group.1'
    end
    it "should allow overriding Solr's access control suffix" do
      module Hydra
        module Collections
          class SearchService
            def solr_access_control_suffix(key)
              "edit_#{key}_customfield"
            end
          end
        end
      end
      @service = Hydra::Collections::SearchService.new({}, '')
      params = @service.apply_gated_search({}, {})
      @public_query = params[:fq].first.split(' OR ')[0]
      @public_query.should == 'edit_group_customfield:public'
    end
  end
end
