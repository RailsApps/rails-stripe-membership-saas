include Warden::Test::Helpers 
Warden.test_mode!

RSpec.describe 'Navigation links' do

  before(:each) do
    visit root_path
  end

  after(:each) do
    Warden.test_reset!
  end

  it 'allows visitor to arrive on the home page' do
    expect(current_path).to eq root_path
  end

  it 'allows visitor to view navigation links' do
    expect(page).to have_link 'Home'
    expect(page).to have_link 'Sign in'
    expect(page).to have_link 'Sign up'
  end

  it 'allows visitor to click on the Sign up link' do
    click_link("Sign up")
    expect(current_path).to eq '/users/sign_up'
  end

  it 'allows visitor to type a correct path in the address bar' do
    visit '/users/sign_up?plan=gold'
    expect(current_path).to eq '/users/sign_up'
  end

  it 'allows visitor to arrive on sign_up page when typing an incorrect plan in the address bar' do
    visit '/users/sign_up?plan=hobo'
    expect(current_path).to eq '/users/sign_up'
  end

end