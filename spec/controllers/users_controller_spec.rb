require 'stripe'

include Warden::Test::Helpers
Warden.test_mode!

RSpec.configure do
  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # UsersController. Be sure to keep this updated too.
  def valid_session
    valid_session = { user_id: 1 }
  end

  def valid_session2
    valid_session2 = { user_id: 2 }
  end
end

RSpec.describe UsersController, type: :controller do

  before(:each) do
    @user = FactoryGirl.build(:user)
    @user.role = "admin"
  end

  after(:each) do
    Warden.test_reset!
  end

  context "GET #index" do
    it 'success' do
      @user.save!
      expect(response).to be_success
    end

    it "assigns @users" do
      @user.save!
      sign_in @user
      expect(@user.id).to eq 1
      expect(@user.email).to eq 'test@example.com'
      expect(@user.persisted?).to eq true
      get :index
      expect(assigns[:users]).to eq User.all
    end
  end

  context "GET #show" do
    it "is successful" do
      expect(@user._validators?).to eq true
      @user.save!
      sign_in @user
      get :show, { id: @user.id }, valid_session
      expect(Rails.logger.info response.body).to eq true
      expect(Rails.logger.warn response.body).to eq true
      expect(Rails.logger.debug response.body).to eq true
      expect(response).to be_success
    end

    it "finds the right user" do
      @user = FactoryGirl.build(:user, email: 'newuser@example.com')
      @user.role = 'admin'
      @user.save!
      sign_in @user
      get :show, { id: @user.id }, valid_session2
      expect(response).to be_success
      expect(@user.id).to eq 1
    end
  end
end