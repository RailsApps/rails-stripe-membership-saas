#require 'helpers/session_helpers'
#require 'utilities'
require 'pry'

include Warden::Test::Helpers
Warden.test_mode!

#RSpec.configure do
  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # UsersController. Be sure to keep this updated too.
#  def valid_admin_session
 #   valid_admin_session = { "user_id" => 1 }
  #end
## are we using this ^^^ 
#end

#RSpec.configure do

 # after(:each) do
  #  Warden.test_reset!      
  #end

#end

#describe UsersController, type: :controller, js: true do
RSpec.describe UsersController, type: :controller do

  after(:each) do
    Warden.test_reset!      
  end

  before (:each) do
    @user = FactoryGirl.create(:user, role: :'admin')
  end

  describe "GET 'index'" do
    it "renders the index template" do
      login_as(@user, scope: :user)
      get 'index'
      expect(response).to be_success
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET 'show'" do
    it "should find the right user" do
binding.pry
      login_as(@user, scope: :user)
      get 'show', { user_id: :'1' }
#      get :show, id: @user.id
      expect(assigns(:user)).to eq @user
      expect(response).to have_http_status(:created)
    end
  end

  describe "index" do
    it "renders the index template" do
      get :index
      expect(response).to render_template("index")
      expect(response.body).to eq ""
    end

    it "renders the users/index template" do
      get :index
      expect(response).to render_template("users/index")
      expect(response.body).to eq ""
    end
  end


#  let!(:user) { FactoryGirl.create(:user) }     # Let queries the database once, and then saves the valid_user object locally

#  before(:each) do
#    let!(:user) { FactoryGirl.create(:user) }     # Let queries the database once, and then saves the valid_user object locally
 #   let(:user) { User.find_by_email(email) }     # Let queries the database once, and then saves the valid_user object locally
 #before (:each) do
 #   @user = FactoryGirl.build(:user)
 #end    #context "#sign_in admin" do  














=begin

  describe "GET #show", type: :controller do
# describe "GET #show", type: :view do
    describe "silver user sign in" do
      it "should be successful with silver user" do
#binding.pry
        @user = FactoryGirl.create(:user, email: :'user4@example.com', password: :'please124', password_confirmation: :'please124', role: :'3', plan_id: :'1')
        sign_in(:user, email: :'user4@example.com', password: :'please124')
        expect(current_path).to eq "/content/silver"
      end
    end

 # describe "GET #show", type: :view do
    describe "gold user sign in" do
      it "should be successful with new gold user" do
        @user = FactoryGirl.create(:user, email: :'user5@example.com', password: :'please125', password_confirmation: :'please125', role: :'4', plan_id: :'2')
        sign_in(:user, email: :'user5@example.com', password: :'please125')
        expect(current_path).to eq "/content/gold"
      end
    end

    describe "platinum user sign in" do
      it "should be successful with new platinum user" do
        @user = FactoryGirl.create(:user, email: :'user6@example.com', password: :'please126', password_confirmation: :'please126', role: :'5', plan_id: :'3')
        sign_in(:user, email: :'user6@example.com', password: :'please126')
        expect(current_path).to eq "/content/platinum"
      end
    end

    describe "admin sign in" do
      it "should be successful with admin" do
        @user = FactoryGirl.create(:user)
        sign_in(:user, email: :'test@example.com', password: :'please123')
        expect(current_path).to eq "/users"
      end
    end
  end
end
=end

end