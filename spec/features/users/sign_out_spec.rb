include Features::SessionHelpers
include Warden::Test::Helpers
Warden.test_mode!
    
# Feature: Sign out
#   As a user
#   I want to sign out
#   So I can protect my account from unauthorized access
feature 'Sign out', :devise do

  before(:each) do
    FactoryGirl.reload 
  end

  after(:each) do
    Warden.test_reset!
  end

  # Scenario: User signs out successfully
  #   Given I am signed in
  #   When I sign out
  #   Then I see a signed out message
  scenario 'user signs out successfully' do
    user = FactoryGirl.create(:user)
    sign_in(user.email, user.password)
    expect(page).to have_content 'Signed in successfully.'
    expect(page).to have_content I18n.t 'devise.sessions.signed_in'
    click_link 'Sign out'
    expect(page).to have_content 'Signed out successfully.'
    expect(page).to have_content I18n.t 'devise.sessions.signed_out'
  end
end