RSpec.describe 'Navigation links' do
  it 'allows visitor to view navigation links' do
    visit root_path
    expect(page).to have_link 'Home'
    expect(page).to have_link 'Sign in'
    expect(page).to have_link 'Sign up'
  end

  it 'allows visitor to click on the Sign up link' do
    visit root_path
    expect(current_path).to eq '/'
    visit '/users/sign_up?plan=silver'
    expect(current_path).to eq '/users/sign_up'
  end
end