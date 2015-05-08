include Warden::Test::Helpers 
Warden.test_mode!

RSpec.describe 'Visitor visits and sees site entrance points' do

  let(:stripe_helper) { StripeMock.create_test_helper }

  after(:each) do
    Warden.test_reset!
  end

  it 'allows visitor to arrive and see the Sign Up link' do
    visit '/'
    expect(current_path).to eq root_path
    expect(page).to have_content 'Sign up'
     expect(page).to have_link 'Sign up'
  end
    
  it 'allows visitor to see the Subscribe buttons' do
    visit '/'
    expect(page).to have_content 'Subscribe'
    expect(page).to have_link 'Subscribe'
  end

  it 'does not allow visitor to see the product page' do
    visit '/'
    visit '/products/product.pdf'
    expect(page).to have_content 'You need to sign in or sign up before continuing.'
  #  expect(page).to have_link 'Subscribe'
  end

  it 'does not allow visitor to see the protected content pages' do
    visit '/'
    visit 'content/silver'
    expect(page).to have_content 'You need to sign in or sign up before continuing.'
#    expect(page).to have_link 'Subscribe'
  end

end