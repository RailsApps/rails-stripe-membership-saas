require 'stripe_mock'

include Features::SessionHelpers
include Warden::Test::Helpers
Warden.test_mode!

RSpec.configure do |config|

  config.before(:each) do
    StripeMock.start
    FactoryGirl.reload
  end

  config.after(:each) do
    StripeMock.stop
    Warden.test_reset!
  end
end

# Feature: Sign up
#   As a visitor
#   I want to sign up
#   So I can visit protected areas of the site
feature 'Sign Up', :devise, type: :controller, js: true do

  before do
    CreatePlanService.new.call
  end

  # Scenario: Visitor can sign up with valid email address and password
  #   Given I am not signed in
  #   When I sign up with a valid email address and password
  #   Then I see a successful sign up message
  scenario 'visitor can sign up as a silver subscriber' do
    pending 'signups need more work'
    visit '/users/sign_up?plan=silver'
    expect(current_path).to eq '/users/sign_up'
    sign_up_silver
    expect(page).to have_content 'Welcome! You have signed up successfully.'
  end

  scenario 'visitor can sign up as a gold subscriber' do
    pending 'signups need more work'
    visit '/users/sign_up?plan=gold'
    expect(current_path).to eq '/users/sign_up'
    sign_up_gold
    expect(page).to have_content 'Welcome! You have signed up successfully.'
  end

  scenario 'visitor can sign up as a platinum subscriber' do
    pending 'signups need more work'
    sign_up_platinum
    expect(page).to have_content 'Welcome! You have signed up successfully.'
  end
end