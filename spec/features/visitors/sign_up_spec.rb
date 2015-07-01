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

  let(:stripe_helper) { StripeMock.create_test_helper }

  before do
    CreatePlanService.new.call
  end

  after(:each) do
    Warden.test_reset!
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
    sign_up_gold('user5@example.com', 'please125', 'please125')
    expect(page).to have_content 'Welcome! You have signed up successfully.'
  end

  scenario 'visitor can sign up as a platinum subscriber' do
    pending 'signups need more work'
   #stripe_token = stripe_helper.generate_card_token(card_number: "4242424242424242", exp_month: 9, exp_year: 2019)
   #sign_up_platinum('user6@example.com', 'please126', 'please126', stripe_token)
    sign_up_platinum('user6@example.com', 'please126', 'please126')
   #expect(current_path).to eq '/users/sign_up?plan=platinum'
    expect(page).to have_content 'Welcome! You have signed up successfully.'
  end
end