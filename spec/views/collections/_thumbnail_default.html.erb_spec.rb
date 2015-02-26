require 'spec_helper'

describe 'collections/_thumbnail_default.html.erb' do
  let(:document) { SolrDocument.new :id => 'xyz', :format => 'a', :thumbnail_url => 'http://localhost/logo.png' }
  let :blacklight_config do
    Blacklight::Configuration.new do |config|
      config.index.thumbnail_field = :thumbnail_url
    end
  end

  before do
    assign :response, double(:params => {})
    allow(view).to receive(:blacklight_config).and_return(blacklight_config)
    allow(view).to receive(:render_grouped_response?).and_return(false)
    allow(view).to receive(:current_search_session).and_return nil
    allow(view).to receive(:search_session).and_return({})
    allow(view).to receive(:url_for_document).and_return('/foo')
    allow(view).to receive(:session_tracking_params).and_return({})
    render 'collections/thumbnail_default', document: document, document_counter: 1
  end

  it "renders a thumbnail" do
    expect(rendered).to have_selector 'div.document-thumbnail a img[src="http://localhost/logo.png"]'
  end
end
