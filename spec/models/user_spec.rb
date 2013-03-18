require 'spec_helper'

describe User do

  before(:each) do
    @attr = {
      :name => "Example User",
      :email => "user@example.com",
      :password => "changeme",
      :password_confirmation => "changeme"
    }
  end

  it "should create a new instance given a valid attribute" do
    User.create!(@attr)
  end

  it "should require an email address" do
    no_email_user = User.new(@attr.merge(:email => ""))
    no_email_user.should_not be_valid
  end

  it "should accept valid email addresses" do
    addresses = %w[user@foo.com THE_USER@foo.bar.org first.last@foo.jp]
    addresses.each do |address|
      valid_email_user = User.new(@attr.merge(:email => address))
      valid_email_user.should be_valid
    end
  end

  it "should reject invalid email addresses" do
    addresses = %w[user@foo,com user_at_foo.org example.user@foo.]
    addresses.each do |address|
      invalid_email_user = User.new(@attr.merge(:email => address))
      invalid_email_user.should_not be_valid
    end
  end

  it "should reject duplicate email addresses" do
    User.create!(@attr)
    user_with_duplicate_email = User.new(@attr)
    user_with_duplicate_email.should_not be_valid
  end

  it "should reject email addresses identical up to case" do
    upcased_email = @attr[:email].upcase
    User.create!(@attr.merge(:email => upcased_email))
    user_with_duplicate_email = User.new(@attr)
    user_with_duplicate_email.should_not be_valid
  end

  describe "passwords" do

    before(:each) do
      @user = User.new(@attr)
    end

    it "should have a password attribute" do
      @user.should respond_to(:password)
    end

    it "should have a password confirmation attribute" do
      @user.should respond_to(:password_confirmation)
    end
  end

  describe "password validations" do

    it "should require a password" do
      User.new(@attr.merge(:password => "", :password_confirmation => "")).
        should_not be_valid
    end

    it "should require a matching password confirmation" do
      User.new(@attr.merge(:password_confirmation => "invalid")).
        should_not be_valid
    end

    it "should reject short passwords" do
      short = "a" * 5
      hash = @attr.merge(:password => short, :password_confirmation => short)
      User.new(hash).should_not be_valid
    end

  end

  describe "password encryption" do

    before(:each) do
      @user = User.create!(@attr)
    end

    it "should have an encrypted password attribute" do
      @user.should respond_to(:encrypted_password)
    end

    it "should set the encrypted password attribute" do
      @user.encrypted_password.should_not be_blank
    end

  end

  describe "expire" do

    before(:each) do
      @user = User.create!(@attr)
    end

    it "sends an email to user" do
      @user.expire
      ActionMailer::Base.deliveries.last.to.should == [@user.email]
    end

  end

  describe "#update_plan" do
    before do
      @user = FactoryGirl.create(:user, email: "test@example.com")
      @role1 = FactoryGirl.create(:role, name: "silver")
      @role2 = FactoryGirl.create(:role, name: "gold")
      @user.add_role(@role1.name)
    end

    it "updates a users role" do
      @user.roles.first.name.should == "silver"
      @user.update_plan(@role2)
      @user.roles.first.name.should == "gold"
    end

    it "wont remove original role from database" do
      @user.update_plan(@role2)
      Role.all.count.should == 2
    end
  end


  describe ".update_stripe" do


    context "with a non-existing user" do

      before do
        successful_stripe_response = StripeHelper::Response.new("success")
        Stripe::Customer.stub(:create).and_return(successful_stripe_response)
        @user = User.new(email: "test@testign.com", stripe_token: 12345, name: 'tester', password: 'password')
        @role = FactoryGirl.create(:role, name: "silver")
        @user.add_role(@role.name)
      end

      it "creates a new user with a succesful stripe response" do
        @user.save!
        new_user = User.last
        new_user.customer_id.should eq("youAreSuccessful")
        new_user.last_4_digits.should eq("4242")
        new_user.stripe_token.should be_nil
      end

    end
  end
end
