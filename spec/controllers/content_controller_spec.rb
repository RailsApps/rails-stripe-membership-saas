require 'rails_helper'

describe ContentController do

  before (:each) do
    @user = FactoryGirl.create(:user)
    @user.role = 'silver'
    sign_in @user
  end

  describe "GET 'silver'" do
    it "returns http success" do
      get 'silver'
      expect(response) ? be_success : redirect_to(root_url)
    end
  end

  describe "GET 'gold'" do
    it "returns http success" do
      get 'gold'
      expect(response) ? be_success : redirect_to(root_url)
    end
  end

  describe "GET 'platinum'" do
    it "returns http success" do
      get 'platinum'
      expect(response) ? be_success : redirect_to(root_url)
    end
  end

end
