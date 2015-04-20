#require 'pry'
require 'support/utilities'
# template : http://stackoverflow.com/questions/8216275/factory-girl-failing-rspec-validation-tests
# user = Factory.build(:user, :username=>"foo")
#include Celluloid
#include SuckerPunch::Job

#include Features::SessionHelpers
include Warden::Test::Helpers       # 20141213 added Warden
Warden.test_mode!


#=begin
## This code is from rails-signup-download.
## We are not using, because we do not allow unverified by email users.
# Feature: Sign up
#   As a visitor
#   I want to sign up
#   So I can visit protected areas of the site
feature 'Sign Up', :devise, type: :feature do #, :js => true do

    after(:each) do
      Warden.test_reset!
    end
  # Scenario: Visitor can sign up with valid email address and password
  #   Given I am not signed in
  #   When I sign up with a valid email address and password
  #   Then I see a successful sign up message
  scenario 'visitor can sign up with valid email address and password' do
 #binding.pry
    visitor_sign_up_with('validaddressandpassword@example.com', 'changmenow', 'chamgemenow')
    expect(page).to have_content 'Welcome! You have signed up successfully.'
  end

  # Scenario: Visitor cannot sign up with invalid email address
  #   Given I am not signed in
  #   When I sign up with an invalid email address
  #   Then I see an invalid email message
  scenario 'visitor cannot sign up with invalid email address' do
    visitor_sign_up_with('bogus', 'changeme', 'chamgeme')
    expect(page).to have_content 'Email is invalid'
  end

  # Scenario: Visitor cannot sign up without password
  #   Given I am not signed in
  #   When I sign up without a password
  #   Then I see a missing password message
  scenario 'visitor cannot sign up without password' do
    sign_up_with('nopassword@example.com', '', '')
    expect(page).to have_content "Password can't be blank"
  end

  # Scenario: Visitor cannot sign up with a short password
  #   Given I am not signed in
  #   When I sign up with a short password
  #   Then I see a 'too short password' message
  scenario 'visitor cannot sign up with a short password' do
    sign_up_with('shortpassword@example.com', 'please', 'please')
    expect(page).to have_content "Password is too short"
  end

  # Scenario: Visitor cannot sign up without password confirmation
  #   Given I am not signed in
  #   When I sign up without a password confirmation
  #   Then I see a missing password confirmation message
  scenario 'visitor cannot sign up without password confirmation' do
    sign_up_with('nopasswordconfirmation@example.com', 'changemenow', '')
    expect(page).to have_content "Password confirmation doesn't match"
  end

  #Scenario: Visitor cannot sign up with mismatched password and confirmation
    #Given I am not signed in
    #When I sign up with a mismatched password confirmation
    #Then I should see a mismatched password message
  
  scenario 'visitor cannot sign up with mismatched password and confirmation' do
    sign_up_with('mismatchedpasswordconfirmation@example.com', 'changemenow', 'mismatch')
    expect(page).to have_content "Password confirmation doesn't match"
  end
end