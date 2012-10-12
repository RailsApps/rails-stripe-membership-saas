require 'spec_helper'

describe ContentController do

  describe "GET 'silver'" do
    it "returns http success" do
      get 'silver'
      response.should be_success
    end
  end

  describe "GET 'gold'" do
    it "returns http success" do
      get 'gold'
      response.should be_success
    end
  end

  describe "GET 'platinum'" do
    it "returns http success" do
      get 'platinum'
      response.should be_success
    end
  end

end
