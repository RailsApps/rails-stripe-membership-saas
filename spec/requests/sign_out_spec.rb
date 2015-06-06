describe 'User Sign out', :devise, type: :request, js: true do

  after(:each) do
    Warden.test_reset!
  end

  it 'signs out successfully' do
    user = FactoryGirl.create(:user)
    user.role = 'admin'
    user.save
    visit new_user_session_path
    fill_in 'Email', with: 'test@example.com'
    fill_in 'Password', with: 'please123'
    click_button 'Sign in'
    expect(page).to have_content 'Signed in successfully.'
    expect(page).to have_content I18n.t 'devise.sessions.signed_in'
    click_link 'Sign out'
    expect(page).to have_content 'Signed out successfully.'
    expect(page).to have_content I18n.t 'devise.sessions.signed_out'
  end
end