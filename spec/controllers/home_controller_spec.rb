require 'rails_helper'

describe HomeController do

  describe "GET 'index'" do
    it "should be successful" do
      get 'index'
      expect(response).to be_success
    end
  end

end
