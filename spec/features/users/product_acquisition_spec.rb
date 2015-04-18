include Warden::Test::Helpers
Warden.test_mode!

# Feature: Product acquisition
#   As a user
#   I want to download the product
#   So I can complete my acquisition
feature 'Product acquisition' do

  after(:each) do
    Warden.test_reset!
  end

  # Scenario: Download the product
  #   Given I am a user
  #   When I click the 'Download' button
  #   Then I should receive a PDF file
  scenario 'Download the product' do
    user = FactoryGirl.create(:user)
    login_as(user, scope: :user)
    visit root_path
    expect(page).to have_content 'Download a free book'
    click_link_or_button 'Download PDF'
    expect(page.response_headers['Content-Type']).to have_content 'application/pdf'
  end

end
