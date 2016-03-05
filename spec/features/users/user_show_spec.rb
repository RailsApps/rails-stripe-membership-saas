include Warden::Test::Helpers
Warden.test_mode!

# Feature: User profile page
#   As a user
#   I want to visit my user profile page
#   So I can see my personal account data
feature 'User profile page', :devise, js: true do

  after(:each) do
    Warden.test_reset!
  end

  # Scenario: User sees own profile
  #   Given I am signed in
  #   When I visit the user profile page
  #   Then I see my own email address
  scenario 'user sees own profile' do
    user = FactoryGirl.build(:user)
    user.role = 'admin'
    user.save!
    login_as(user, scope: :user)
    visit user_path(user)
    expect(page).to have_content 'User'
    expect(page).to have_content user.email
  end

  # Scenario: User cannot see another user's profile
  #   Given I am signed in
  #   When I visit another user's profile
  #   Then I see that access is denied to me
  scenario "user cannot see another user's profile" do
    @user = FactoryGirl.build(:user, email: 'johnny@appleseed.com')
    @user.role = 'admin'
    @user.save!
    login_as(@user, scope: :user)
    visit '/users'
    expect(current_path).to eq '/users'
    expect(@user.id).to eq 1
    click_link 'Sign out'
    expect(current_path).to eq "/"

    plans = CreatePlanService.new.call
    @other = FactoryGirl.build(:user,
      email: 'frankie@appleseed.com',
      password: 'changemenow',
      password_confirmation: 'changemenow',
      role: 3,
      plan_id: 1
      )
    @other.save!
    expect(@other.role).to eq 'gold'
    expect(@other.plan_id).to eq 1
    expect(@other.email).to eq 'frankie@appleseed.com'
    visit new_user_session_path
    expect(current_path).to eq '/users/sign_in'
    sign_in(@other.email, @other.password)
    expect(page).to have_content 'Signed in successfully.'
    expect(current_path).to eq '/content/gold'
    visit user_path(@other)
    expect(page).to have_content 'Edit account'
    expect(page).to have_content 'frankie@appleseed.com'
    expect(current_path).to eq '/users/2'
    click_link 'Sign out'
    expect(current_path).to eq '/'
    expect(current_path).to eq root_path
    expect(page).to have_content 'Signed out successfully.'

    expect(@user.active_for_authentication?).to be true
    expect(@other.active_for_authentication?).to be true
    expect(@user.persisted?).to be true
    expect(@other.persisted?).to be true
    expect(@user.admin?).to be true
    expect(@other.admin?).to be false
    expect(@user.role).to eq 'admin'
    expect(@other.role).to eq 'gold'
    expect(@user.sign_in_count).to eq 1

    # we have proven both users can come and go and all is well above
    # now we have one user try to visit another user's profile below
    sign_in(@other.email, @other.password)
    expect(current_path).to eq '/content/gold'
    expect(page).to have_content 'Signed in successfully.'
    expect(@other.plan_id).to eq 1
    expect(@other.role).to eq 'gold'
    current_user = User.find(2)
    expect(current_user.sign_in_count?).to be true
    expect(current_user.sign_in_count).to eq 2

    visit '/users/2'
    expect(current_path).to eq '/users/2'
    visit user_path(@other)
    expect(current_path).to eq '/users/2'
    visit user_path(@other, scope: :other)
    expect(current_path).to eq '/users/2'
    expect(@other.email).to eq 'frankie@appleseed.com'

    visit user_path(2)
    expect(current_path).to eq '/users/2'
    visit '/users/2'
    expect(current_path).to eq '/users/2'

    visit user_path(1)
    expect(current_url).to match /denied\.$/

    visit '/users/1'
    expect(current_url).to match /denied\.$/

    visit '/users/2'
    click_link 'Sign out'
    expect(page).to have_content "Signed out successfully."
    
    ## user #2 has been prevented from seeing user #1 profile
    ## all is well up to this point, and everyone is signed out
    ## with user #2 signed out, access to profile is not available
    visit '/users/2'
    expect(page).to have_content "You need to sign in or sign up before continuing."

    # we sign in as 'other', and attempt to visit user's profile
    visit new_user_session_path
    sign_in(@other.email, @other.password)
    expect(current_path).to eq '/content/gold'
    visit '/users/1'       # access is denied, as user #2 cannot see user #1's profile
    expect(current_url).to match /denied\.$/
    expect(current_path).not_to eq '/user/1'

    visit users_path(2)    # this will pass, as other can see their own profile
    expect(current_path).to eq '/users.2'
    click_link 'Sign out'
    expect(current_path).to eq '/'
    expect(page).to have_content "Signed out successfully."

    # both users are now signed out, we are on the root_path
    # we now 'destroy the users'
    user = {}
    other = {}

    # here we attempt to view another's profile in several ways
    visit users_path(1)    # all of these should fail, as no signed in user exists
    expect(page).to have_content 'You need to sign in or sign up before continuing.'
    visit users_path(user, scope: :other)
    expect(current_path).to eq '/users/sign_in'
    expect(page).to have_content 'You need to sign in or sign up before continuing.'
    visit user_path(2)
    expect(page).to have_content 'You need to sign in or sign up before continuing.'
    visit user_path(1)
    expect(page).to have_content 'You need to sign in or sign up before continuing.'
    visit users_path(other)
    expect(page).to have_content 'You need to sign in or sign up before continuing.'

    # tight as a drum
    # now, we sign in again as Admin user

    @user = User.first
    @user.role = 'admin'
    @user.save!
    login_as(@user, scope: :user)
    visit '/users'
    expect(current_path).to eq '/users'
    expect(@user.id).to eq 1
    expect(page).to have_content 'johnny@appleseed.com'
    expect(page).to have_content 'frankie@appleseed.com'
    expect(page).to have_select :user_role, 'Admin'
    expect(page).to have_content 'Gold'
    expect(page).to have_content 'frankie@appleseed.com'
    expect(page).to have_select :user_role, 'Gold'
    expect(page).to have_content 'Delete user'
    visit users_path(2)
    expect(current_path).to eq '/users.2'
    expect(@user.sign_in_count?).to be true
    expect(@user.sign_in_count).to eq 2
    click_link 'Sign out'
    expect(current_path).to eq root_path
  end
end