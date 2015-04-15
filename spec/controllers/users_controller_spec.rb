require 'rails_helper'

describe UsersController do

  before (:each) do
    @user = FactoryGirl.create(:user)
    sign_in @user
  end

  describe "GET 'show'" do
    
    it "should be successful" do
      get :show, :id => @user.id
      expect(response).to be_success
    end
    
    it "should find the right user" do
      get :show, :id => @user.id
      expect(assigns(:user)).to eq(@user)
    end
    
  end

end
