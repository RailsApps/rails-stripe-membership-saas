require 'rails_helper'

describe ContentController do

  before (:each) do
    @user = FactoryGirl.create(:user)
    sign_in @user
    @user.add_role :silver
  end

  describe "GET 'silver'" do
    it "returns http success" do
      get 'silver'
      expect(response).to @user.has_role?(:silver) ? be_success : redirect_to(root_url)
    end
  end

  describe "GET 'gold'" do
    it "returns http success" do
      get 'gold'
      expect(response).to @user.has_role?(:gold) ? be_success : redirect_to(root_url)
    end
  end

  describe "GET 'platinum'" do
    it "returns http success" do
      get 'platinum'
      expect(response).to @user.has_role?(:platinum) ? be_success : redirect_to(root_url)
    end
  end

end
