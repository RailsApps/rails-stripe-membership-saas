include Warden::Test::Helpers
Warden.test_mode!

# Feature: User index page
#   As an admin user
#   I want to see a list of all users
#   So I can see all users, their email and plan
feature 'User index page', :devise, js: true do

  after(:each) do
    Warden.test_reset!
  end

  # Scenario: Admin user sees all users on index page
  #   Given I am signed in
  #   When I visit the user index page
  #   Then I see all users, their email and plan
  scenario 'admin user sees all users on index page' do
    @user = FactoryGirl.build(:user)
    @user.role = 'admin'
    @user.save!
    login_as(@user, scope: :user)
    visit users_path
    expect(current_path).to eq '/users'
    expect(page).to have_content @user.email
    expect(page).to have_content 'Admin'
  end
end