
include Utilities
include Capybara::RSpecMatchers
require 'capybara/dsl'
require 'helpers/session_helpers'
require 'utilities'
require 'pry'

# template : http://stackoverflow.com/questions/8216275/factory-girl-failing-rspec-validation-tests
# user = Factory.build(:user, :username=>"foo")
#include Celluloid
#include SuckerPunch::Job

#include Features::SessionHelpers
include Warden::Test::Helpers 
Warden.test_mode!


# Feature: Sign up
#   As a visitor
#   I want to sign up
#   So I can visit protected areas of the site
#feature 'Sign Up', :devise, :js => true do
feature 'Sign Up', :devise do

    after(:each) do
      Warden.test_reset!
    end
  # Scenario: Visitor can sign up with valid email address and password
  #   Given I am not signed in
  #   When I sign up with a valid email address and password
  #   Then I see a successful sign up message

  scenario 'visitor can sign up as a silver subscriber' do
#binding.pry
    user = FactoryGirl.create(:user)
    sign_up('user4@example.com', 'please124', 'please124')
    expect(page).to have_content 'Welcome! You have signed up successfully.'
  end

  scenario 'visitor can sign up as a gold subscriber' do
    sign_up('user5@example.com', 'please125', 'please125')
    expect(page).to have_content 'Welcome! You have signed up successfully.'
  end

  scenario 'visitor can sign up as a platinum subscriber' do
    sign_up('user6@example.com', 'please126', 'please126')
    expect(page).to have_content 'Welcome! You have signed up successfully.'
  end

end