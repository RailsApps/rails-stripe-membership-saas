# Feature: Sign out
#   As a user
#   I want to sign out
#   So I can protect my account from unauthorized access
feature 'Sign out', :devise, js: true do

  let(:user) { User.find_by_email(email) }     # Let queries the database once, and then saves the valid_user object locally
 #before { @user = User.find_by_email(email) } # Before queries the database before each spec. 

  # Scenario: User signs out successfully
  #   Given I am signed in
  #   When I sign out
  #   Then I see a signed out message
  scenario 'user signs out successfully' do
    if current_path == nil
      visit '/'
    else
  #   user = FactoryGirl.build(:user)
  #   user.role = 1
  #   user.save
  #   sign_in('test@example.com', 'please123')
  #   expect(page).to have_content 'Signed in successfully.'
  #   click_link 'Sign out'
      visit '/users/sign_out'
      expect(page).to have_content 'Signed out successfully.'
    end
  end
end