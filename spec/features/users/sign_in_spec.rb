require 'helpers/session_helpers'
require 'utilities'
require 'pry'

include Warden::Test::Helpers
Warden.test_mode!

RSpec.configure do |config|

  config.before(:each) do
    FactoryGirl.reload 
  end

  config.after(:each) do
    Warden.test_reset!
  end
end

# Feature: Sign in
#   As a user
#   I want to sign in
#   So I can visit protected areas of the site
#feature 'Sign in', :devise, type: :feature do
#feature 'Sign in', :devise, :js => true, type: :request do 
feature 'User', :devise, js: true do 
 
#  let(:user) { FactoryGirl.build(:user) }

  # Scenario: User cannot sign in if not registered
  #   Given I do not exist as a user
  #   When I sign in with valid credentials
  #   Then I see an invalid credentials message
  scenario 'cannot sign in if not registered' do  # failing 20150429
#binding.pry
    user = FactoryGirl.create(:user, role: :'admin')
    visit new_user_session_path
    expect(current_path).to eq '/users/sign_in'
    sign_in('test@example.com', :'notmypassword')
    expect(page).to have_content 'Invalid email or password.'
  end

  # Scenario: User can sign in with valid credentials
  #   Given I exist as a user
  #   And I am not signed in
  #   When I sign in with valid credentials
  #   Then I see a success message
  scenario 'can sign in with valid credentials' do
#binding.pry
    user = FactoryGirl.build(:user, role: :'admin')
    visit new_user_session_path
    expect(current_path).to eq "/users/sign_in"
    sign_in('test@example.com', :'please123')
    expect(page).to have_content 'Signed in successfully.'
    expect(current_path).to eq '/users'
#   sign_in
  end

  # Scenario: User cannot sign in with wrong email
  #   Given I exist as a user
  #   And I am not signed in
  #   When I sign in with a wrong email
  #   Then I see an invalid email message
  scenario 'cannot sign in with wrong email' do
   #user = FactoryGirl.build(:user)
    visit new_user_session_path
    sign_in('invalid@example.com', :'please123')
    expect(page).to have_content 'Invalid email or password.'
  end

  # Scenario: User cannot sign in with wrong password
  #   Given I exist as a user
  #   And I am not signed in
  #   When I sign in with a wrong password
  #   Then I see an invalid password message
  scenario 'cannot sign in with wrong password' do
    user = FactoryGirl.create(:user, :'admin')
    visit new_user_session_path
    sign_in('test@example.com', :'invalidpass')
    expect(page).to have_content 'Invalid email or password.'
  end
end