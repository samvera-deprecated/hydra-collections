require 'spec_helper'

describe "Creating collection" do
  let(:user) { FactoryGirl.create(:user) }
  before do
    login_as(user, scope: :user)
    visit '/collections'
  end

  specify do
    click_button 'Create Collection'
    fill_in 'Title', with: 'Test title'
    fill_in 'Description', with: 'Test description'
    click_button 'Create Collection'
    expect(page).to have_content 'Test title'
  end
end
