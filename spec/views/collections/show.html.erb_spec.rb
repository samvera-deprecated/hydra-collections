require 'spec_helper'

describe 'collections/show.html.erb' do
  let(:response) { Blacklight::Solr::Response.new(sample_response, {}) }
  let(:collection) { mock_model(Collection, id: '123', title: "My Collection", description: "Just a collection") }

  let(:blacklight_config) { CatalogController.blacklight_config }
  let(:member_docs) { [ SolrDocument.new(id: '234'), SolrDocument.new(id: '456') ] }
  before do
    allow(view).to receive(:blacklight_config).and_return(blacklight_config)
    allow(view).to receive(:search_session).and_return({})
    allow(view).to receive(:current_search_session).and_return nil
    allow(view).to receive(:render_index_doc_actions).and_return nil
    view.lookup_context.prefixes += ['catalog']
    assign(:response, response)
    assign(:collection, collection)
    assign(:member_docs, member_docs)
    stub_template 'catalog/_index_header_default.html.erb' => 'Document Title'
    render
  end

  it "draws the page" do
    expect(rendered).to have_content "My Collection"
  end

  let(:sample_response) do
    {"responseHeader" => {"params" =>{"rows" => 3}},
     "docs" =>[]
    }
  end
end

