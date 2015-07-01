require 'stripe_mock'
require 'stripe_mock/server'

include Warden::Test::Helpers
Warden.test_mode!

RSpec.configure do
  @attr = {
    name: "Test User",
    email: "testuser@example.com",
    password: "changeme",
    password_confirmation: "changeme",
  }
end

RSpec.describe User do

  before(:each) do
    StripeMock.start
    @user = FactoryGirl.build(:user)
  end

  after(:each) do
    StripeMock.stop
    Warden.test_reset!
  end

  it "responds to email" do
    expect(@user).to respond_to(:email)
  end

  it "#email returns a string" do
    expect(@user.email).to match 'test@example.com'
  end

  it "should create a new instance given a valid attribute" do
    @user.email = 'valid@example.com'
    expect(@user.save!).to be true
  end

  it "should require an email address" do
    expect(@user.email = "").not_to be_falsey
  end

  it "should accept valid email addresses" do
    addresses = %w[user@foo.com THE_USER@foo.bar.org first.last@foo.jp]
    addresses.each do |address|
      @user.email = address.to_s
      expect(@user.save!).not_to be_falsey
    end
  end

  it "should reject invalid email addresses" do
    addresses = %w[user@foo,com user_at_foo.org example.user@foo.]
    addresses.each do |address|
      expect(@user.email = address).to_not be true
    end
  end

  it "should reject duplicate email addresses" do
    @user.save
    @duplicate_user = FactoryGirl.build(:user)
    expect(@duplicate_user.save).not_to be true
  end

  it "should reject email addresses identical up to case" do
    @user.save
    @new_user = FactoryGirl.build(:user, email: 'test@example.com'.upcase)
    expect(@new_user.save).not_to be true
  end
end

describe "Passwords" do

  before(:each) do
    @user = FactoryGirl.build(:user)
  end

  after(:each) do
    Warden.test_reset!
  end

  it "should have a password attribute" do
    expect(@user).to respond_to(:password)
    end

  it "should have a password confirmation attribute" do
    expect(@user).to respond_to(:password_confirmation)
  end
end

describe "password validations" do

  before(:each) do
    @user = FactoryGirl.build(:user)
  end

  after(:each) do
    Warden.test_reset!
  end

  it "should require a password" do
    expect(@user.update_attributes(password: "", password_confirmation: "")).to eq false
  end

  it "should require a matching password confirmation" do
    expect(@user.update_attributes(password_confirmation: "invalid")).to be_falsey
  end

  it "should reject short passwords" do
    @user.save!
    short = "a" * 5
    hash = { password: short, password_confirmation: short }
    expect(@user.update_attributes({ password: short, password_confirmation: short })).to be_falsey
    expect(User.new(hash)).not_to be_valid
  end
end

describe "password encryption" do

  before(:each) do
    @user = FactoryGirl.build(:user)
  end

  after(:each) do
    Warden.test_reset!
  end

  it "should have an encrypted password attribute" do
    expect(@user).to respond_to(:password)
    expect(@user).to respond_to(:encrypted_password)
   end

  it "should set the encrypted password attribute" do
    expect(@user.password).not_to be_blank
  end
end

describe "expire" do

  before(:each) do
    @user = FactoryGirl.build(:user)
  end

  after(:each) do
    Warden.test_reset!
  end

  it "sends an email to user" do
    pending 'needs more work'
    @user.save
    @user.expire_email
    expect(ActionMailer::Base.deliveries.last.to).to eq @user.email
  end
end

describe "#update_plan" do

  before(:each) do
    @user = FactoryGirl.build(:user)
    @user1 = FactoryGirl.build(:user, email: 'user1@example.com', role: 2)
  end

  after(:each) do
    Warden.test_reset!
  end

  it "updates a users role" do
    @user.save!
    expect(@user.role).to eq "user"
    @user1.save!
    expect(@user1.role).to eq 'silver'
    @user1.update_attributes({ role: 3 })
    expect(@user1.role).to eq "gold"
  end
end

describe ".update_stripe" do
  context "with a non-existing user" do

    let(:stripe_helper) { StripeMock.create_test_helper }
    let(:stripe_helper) { StripeMock.create_test_helper }

    before(:each) do
      StripeMock.start
      @user = FactoryGirl.build(:user)
    end

    after(:each) do
      StripeMock.stop
      Warden.test_reset!
    end

    it "creates a new stripe customer and card token" do
      customer = Stripe::Customer.create({
        email: 'someone@example.com',
        source: stripe_helper.generate_card_token
      })
      expect(customer.email).to eq 'someone@example.com'
      expect(customer.sources.first.id).to match /^test_cc/
    end

    it "creates a Silver stripe customer" do
      plan = stripe_helper.create_plan(id: 'silver', name: 'Silver', interval: 'month')
      customer = Stripe::Customer.create({
        email: 'silver@example.com',
        description: 'Silver Plan Creation',
        source: stripe_helper.generate_card_token(id: 'silver', amount: 900, currency: 'usd')
      })
      expect(customer.email).to eq('silver@example.com')
      expect(plan.id).to eq 'silver'
      subscription = customer.subscriptions.create(plan: "silver")
      user = Stripe::Customer.retrieve(customer.id)
      expect(user.id).to match /^test_cus/
      expect(user.subscriptions.data[0].id).to match /^test_su/
      expect(user.subscriptions.total_count).to eq 1
      expect(user.subscriptions.data[0].plan.id).to eq 'silver'
      expect(user.subscriptions.data[0].plan.name).to eq 'Silver'
      expect(user.subscriptions.data[0].plan.interval_count).to eq 1
      expect(user.subscriptions.data[0].customer).to match /^test_cus/
      expect(user.subscriptions.data[0].status).to eq 'active'
    end
  end
end