describe 'ProductsController' do

  after(:each) do
    Warden.test_reset!
  end

  describe 'GET #show' do
    it "returns a PDF file for the Admin" do
      user = FactoryGirl.build(:user)
      user.role = 'admin'
      user.save
      login_as(user, scope: :user)
      visit '/'
      expect(page).to have_content 'Products Offered'
      click_link_or_button 'Download PDF'
      expect(page.response_headers['Content-Type']).to have_content 'application/pdf'
    end

    it "returns a PDF file for the User" do
      user = FactoryGirl.build(:user)
      user.role = 'silver'
      user.save
      login_as(user, scope: :user)
      visit '/'
      expect(page).to have_content 'Download a free book'
      click_link_or_button 'Download PDF'
      expect(page.response_headers['Content-Type']).to have_content 'application/pdf'
    end

  end

end