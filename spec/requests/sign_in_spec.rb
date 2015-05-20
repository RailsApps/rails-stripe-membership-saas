describe 'User Sign in', :devise, type: :request, js: true do

  before(:each) do
    @user = FactoryGirl.create(:user)
    visit new_user_session_path
  end

  after(:each) do
    Warden.test_reset!
  end

  it 'can sign in with valid credentials' do
    fill_in 'Email', with: 'test@example.com'
    fill_in 'Password', with: 'please123'
    @user.role = 'admin'
    @user.save
    click_button 'Sign in'
    expect(current_path).to eq '/users'
    expect(page).to have_content 'Signed in successfully.'
    expect(page).to have_content I18n.t 'devise.sessions.signed_in'
  end

  it 'cannot sign in if not registered' do
    fill_in 'Email', with: 'testing@example.com'
    fill_in 'Password', with: 'pleaseletmein'
    click_button 'Sign in'
    expect(page).to have_content 'Invalid email or password.'
    expect(page).to have_content I18n.t 'devise.failure.not_found_in_database', authentication_keys: 'email'
  end

  it 'cannot sign in with wrong email' do
    fill_in 'Email', with: 'invalid@example.com'
    fill_in 'Password', with: 'please123'
    click_button 'Sign in'
    expect(page).to have_content 'Invalid email or password.'
    expect(page).to have_content I18n.t 'devise.failure.not_found_in_database', authentication_keys: 'email'
  end

  it 'cannot sign in with wrong password' do
    fill_in 'Email', with: 'test@example.com'
    fill_in 'Password', with: 'pleaseletmein'
    click_button 'Sign in'
    expect(page).to have_content 'Invalid email or password.'
    expect(page).to have_content I18n.t 'devise.failure.not_found_in_database', authentication_keys: 'email'
  end
end