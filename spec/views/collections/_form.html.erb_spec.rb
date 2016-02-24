require 'spec_helper'

describe 'collections/_form.html.erb' do
  before do
    assign(:collection, stub_model(Collection))
    render
  end

  it "draws the fields" do
    expect(rendered).to have_css 'input#collection_title'
    expect(rendered).to have_css 'label[for="collection_title"]'
    expect(rendered).to have_css 'textarea#collection_description'
    expect(rendered).to have_css 'label[for="collection_description"]'
  end
end
