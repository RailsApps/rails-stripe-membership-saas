include Warden::Test::Helpers
Warden.test_mode!

# Feature: User edit
#   As a user
#   I want to edit my user profile
#   So I can change my email address
feature 'User edit', :devise do

  after(:each) do
    Warden.test_reset!
  end

  # Scenario: User changes email address
  #   Given I am signed in
  #   When I change my email address
  #   Then I see an account updated message
  scenario 'user changes email address' do
    user = FactoryGirl.build(:user)
    user.role = 'admin'
    user.save!
    login_as(user, scope: :user)
    visit edit_user_registration_path(user)
    fill_in 'Email', with: 'newemail@example.com'
    fill_in 'Current password', with: user.password
    click_button 'Update'
    txt1 = I18n.t('devise.registrations.updated')
    txt2 = I18n.t('devise.registrations.update_needs_confirmation')
    expect(txt1).to eq "Your account has been updated successfully."
    expect(txt2).to eq "You updated your account successfully, but we need to verify your new email address. Please check your email and follow the confirm link to confirm your new email address."
    expect(page).to have_content(/.*#{txt1}.*|.*#{txt2}.*/)  # this line is same as above two expect's
  end

  # Scenario: User cannot edit another user's profile
  #   Given I am signed in
  #   When I try to edit another user's profile
  #   Then I see my own 'edit profile' page
  scenario "user cannot cannot edit another user's profile", :user do
    user = FactoryGirl.build(:user)
    user.role = 'admin'
    user.save!
    other = FactoryGirl.build(:user, email: 'other@example.com')
    other.role = 'admin'
    user.save!
    login_as(user, scope: :user)
    visit edit_user_registration_path(other)
    expect(page).to have_content 'Account'
    expect(page).to have_field('Email', with: user.email)
    fill_in 'Email', with: 'anotherprofile@example.com'
    fill_in 'Current password', with: other.password
    click_button 'Update'
    txt = I18n.t('devise.registrations.invalid')
    expect(txt).to eq "Invalid email or password."
  end
end