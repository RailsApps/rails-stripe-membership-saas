include Warden::Test::Helpers 
Warden.test_mode!

RSpec.describe 'Visitor visits and sees site entrance points' do

  before(:each) do
    visit root_path
  end

  after(:each) do
    Warden.test_reset!
  end

  it 'allows visitor to arrive and see the Sign Up link' do
    expect(current_path).to eq root_path
    expect(page).to have_content 'Sign up'
    expect(page).to have_link 'Sign up'
  end
    
  it 'allows visitor to see the first Subscribe button' do
    expect(page).to have_content 'Subscribe'
    expect(page).to have_link 'Subscribe'
  end

  it 'does not allow visitor to see the /products available' do
    visit '/products/product.pdf'
    expect(page).to have_content 'You need to sign in or sign up before continuing.'
  end

  it 'does not allow visitor to see the /content/silver page' do
    visit '/content/silver'
    expect(page).to have_content 'You need to sign in or sign up before continuing.'
  end

  it 'does not allow visitor to see the /content/gold page' do
    visit '/content/gold'
    expect(page).to have_content 'You need to sign in or sign up before continuing.'
  end

  it 'does not allow visitor to see the /content/platinum page' do
    visit '/content/platinum'
    expect(page).to have_content 'You need to sign in or sign up before continuing.'
  end

  it 'does not allow visitor to see the /users page' do
    visit '/users'
    expect(page).to have_content 'You need to sign in or sign up before continuing.'
  end

end