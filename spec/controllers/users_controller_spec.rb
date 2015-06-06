describe UsersController, type: :controller do

  after(:each) do
    Warden.test_reset!      
  end

  before(:each) do
    @user = FactoryGirl.create(:user)
  end

  describe "Users" do
    it "#show users to Admin" do
      @user.role = 1
      expect(@user.admin?).to eq true
      login_as(:user, scope: :user)
      visit '/users'
      expect(current_path).to eq '/users'
      expect(current_path).not_to eq '/users/sign_in'
      expect(response).to be_success
      expect(response).to have_http_status(:ok)
      expect(response).to have_http_status(200)
    end

    it "#show allows silver user to view silver content" do
      expect(@user.role).to eq 'user'
      @user.role = 'silver'
      @user.plan_id = 3
      login_as(:user, scope: :user)
      visit '/content/silver'
      expect(current_path).to eq '/content/silver'
      expect(response).to be_success
      expect(response).to have_http_status(:ok)
      expect(response).to have_http_status(200)
    end

    it "#show does not allow silver user to view platinum content" do
      expect(@user.role).to eq 'user'
      @user.role = 'silver'
      @user.plan_id = 3
      expect(@user.role).to eq 'silver'
      expect(@user.plan_id).to eq 3
      login_as(:user, scope: :silver)
      visit content_platinum_path
      expect(current_path).to eq '/users/sign_in'
      expect(response).to have_http_status(:ok)
      expect(response).to have_http_status(200)
    end

    it "#show does not allow platinum user to view gold content" do
      expect(@user.role).to eq 'user'
      @user.role = 'platinum'
      @user.plan_id = 1
      expect(@user.role).to eq 'platinum'
      expect(@user.plan_id).to eq 1   
      login_as(:user, scope: :platinum)
      visit content_gold_path
      expect(current_path).to eq '/users/sign_in'
      expect(response).to have_http_status(:ok)
      expect(response).to have_http_status(200)
    end
  end
end