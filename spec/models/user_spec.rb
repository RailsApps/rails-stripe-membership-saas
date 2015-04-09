require 'rails_helper'
require 'stripe_mock'
require 'stripe_mock/server'

include Warden::Test::Helpers
Warden.test_mode!
#
RSpec.configure do
  valid_session = { "user_id" => 1 }
  @attr = {
    :name => "Test User",
    :email => "testuser@example.com",
    :password => "changemenow",
    :password_confirmation => "changemenow",
  }
end

RSpec.describe User do

  before(:each) do
    @user = FactoryGirl.create(:user)
  end

  after(:each) do
    Warden.test_reset!
  end

  let(:stripe_helper) { StripeMock.create_test_helper }
    
  subject { @user }

  it { should respond_to(:email) }

  it "#email returns a string" do
    expect(@user.email).to match 'test@example.com'
  end

  it "should have a password attribute" do
    expect(@user).to respond_to(:password)
  end

  it "should have a password confirmation attribute" do
    expect(@user).to respond_to(:password_confirmation)
  end

  it "creates a Silver stripe customer" do
    StripeMock.start
    customer = Stripe::Customer.create({
      email: 'silver@example.com',
      description: 'Silver Plan Creation',
      card: stripe_helper.generate_card_token(:id => 'silver', :amount => 900)
    })
    expect(customer.email).to eq('silver@example.com')
    StripeMock.stop
  end

  it "creates a Silver stripe plan" do
    StripeMock.start
    plan = stripe_helper.create_plan(:id => 'silver', :amount => 900)
    expect(plan.id).to eq('silver')
    expect(plan.amount).to eq(900)
    StripeMock.stop
  end

  it "creates a Gold stripe plan" do
    StripeMock.start
    plan = stripe_helper.create_plan(:id => 'gold', :amount => 1900)
    expect(plan.id).to eq('gold')
    expect(plan.amount).to eq(1900)
    StripeMock.stop
  end

  it "creates a Platinum stripe plan" do
    StripeMock.start
    plan = stripe_helper.create_plan(:id => 'platinum', :amount => 2900)
    expect(plan.id).to eq('platinum')
    expect(plan.amount).to eq(2900)
    StripeMock.stop
  end

  it "generates a stripe card token" do
    StripeMock.start
    card_token = stripe_helper.generate_card_token(last4: "9191", exp_year: 2015)

    cus = Stripe::Customer.create({ :source => card_token })
    card = cus.sources.first
    expect(card.last4).to eq("9191")
    expect(card.exp_year).to eq(2015)
    StripeMock.stop
  end

  it "mocks a incorrect number card error" do
    StripeMock.start
    StripeMock.prepare_card_error(:incorrect_number)

    expect { Stripe::Charge.create }.to raise_error {|e|
      expect(e).to be_a Stripe::CardError
      expect(e.http_status).to eq(402)
      expect(e.code).to eq('incorrect_number')
    }
    StripeMock.stop
  end

  it "mocks a card declined error" do
    StripeMock.start
    StripeMock.prepare_card_error(:card_declined)

    expect { Stripe::Charge.create }.to raise_error {|e|
      expect(e).to be_a Stripe::CardError
      expect(e.http_status).to eq(402)
      expect(e.code).to eq('card_declined')
    }
    StripeMock.stop
  end

  it "mocks a declined card incorrect cvc error" do
    StripeMock.start
    StripeMock.prepare_card_error(:incorrect_cvc)

    expect { Stripe::Charge.create }.to raise_error {|e|
      expect(e).to be_a Stripe::CardError
      expect(e.http_status).to eq(402)
      expect(e.code).to eq('incorrect_cvc')
    }
    StripeMock.stop
  end

  it "mocks an invalid expiry month error" do
    StripeMock.start
    StripeMock.prepare_card_error(:invalid_expiry_month)

    expect { Stripe::Charge.create }.to raise_error {|e|
      expect(e).to be_a Stripe::CardError
      expect(e.http_status).to eq(402)
      expect(e.code).to eq('invalid_expiry_month')
    }
    StripeMock.stop
  end

  it "mocks an invalid expiry year error" do
    StripeMock.start
    StripeMock.prepare_card_error(:invalid_expiry_year)

    expect { Stripe::Charge.create }.to raise_error {|e|
      expect(e).to be_a Stripe::CardError
      expect(e.http_status).to eq(402)
      expect(e.code).to eq('invalid_expiry_year')
    }
    StripeMock.stop
  end

  it "mocks an expired card error" do
    StripeMock.start
    StripeMock.prepare_card_error(:expired_card)

    expect { Stripe::Charge.create }.to raise_error {|e|
      expect(e).to be_a Stripe::CardError
      expect(e.http_status).to eq(402)
      expect(e.code).to eq('expired_card')
    }
    StripeMock.stop
  end

  it "mocks a card declined error" do
    StripeMock.start
    StripeMock.prepare_card_error(:card_declined)

    expect { Stripe::Charge.create }.to raise_error {|e|
      expect(e).to be_a Stripe::CardError
      expect(e.http_status).to eq(402)
      expect(e.code).to eq('card_declined')
    }
    StripeMock.stop
  end

  describe ".update_stripe" do

    let(:stripe_helper) { StripeMock.create_test_helper }
    before { StripeMock.start }
    after { StripeMock.stop }

    context "with a non-existing user" do

      it "creates a new stripe customer and card token" do
        StripeMock.start
        customer = Stripe::Customer.create({
          email: 'someone@example.com',
          card: stripe_helper.generate_card_token
        })
        expect(customer.email).to eq('someone@example.com')
        StripeMock.stop
      end

      it "creates a new user with a succesful stripe response" do
        StripeMock.start
        customer = Stripe::Customer.create({
          email: 'example@example.com',
          card: stripe_helper.generate_card_token(:id => "silver", :amount => 900)
        })
        expect(customer.email).to eq('example@example.com')
        token = customer.card
        @user = User.new(email: "example@example.com", stripe_token: token, name: 'tester', password: 'changeme', password_confirmation: 'changeme')
        @role = FactoryGirl.create(:role, name: "silver")
        @user.add_role(@role.name)
        @user.save
        expect(@user.roles.first.name).to eq('silver')

        customer = Stripe::Customer.retrieve(customer.id)
        expect(customer.id).to match(/^test_cus/)
        expect(customer.card).to match(/^test_tok/)
        StripeMock.stop
      end

      it "should create a new instance given a valid attribute" do
        email_user = FactoryGirl.create(:user)
        email_user.update_attributes(:email => "newinstance@example.com")
        expect(email_user.email.nil?).to be_falsey
      end

      it "should require an email address" do
        no_email_user = FactoryGirl.create(:user)
        no_email_user.update_attributes(:email => "")
        expect(no_email_user.email.nil?).to be_falsey
      end

      it "should accept valid email addresses" do
        StripeMock.start
          customer = Stripe::Customer.create({
          email: 'example@example.com',
          card: stripe_helper.generate_card_token(:id => "silver", :amount => 900)
        })
        token = customer.card
        addresses = %w[user@foo.com THE_USER@foo.bar.org first.last@foo.jp]
        addresses.each do |address|
        valid_email_user = FactoryGirl.build(:user)
        valid_email_user.update_attributes(email: "example@example.com", stripe_token: token, name: 'tester', password: 'changeme', password_confirmation: 'changeme')
        expect(valid_email_user).to be_truthy
        end
        StripeMock.stop
      end

      it "should reject invalid email addresses" do
        StripeMock.start
        addresses = %w[user@foo,com user_at_foo.org example.user@foo.]
        addresses.each do |address|
          user = FactoryGirl.build(:user, email: address)
          expect(user).to be_invalid
        end
        StripeMock.stop
      end

      it "should reject duplicate email addresses" do
        StripeMock.start
        user = FactoryGirl.create(:user)
        expect(FactoryGirl.build(:user)).to be_invalid
        StripeMock.stop
      end
    end

    it "should reject email addresses identical up to case" do
      StripeMock.start
      user = FactoryGirl.build(:user, email: :'upcased@example.com')
      upcased_email = user.email.upcase
      user_with_upcased_email = user.update_attributes(:email => upcased_email)
      expect(user_with_upcased_email).to be true
      StripeMock.stop
    end
  end

  describe "password validations" do

    before(:each) do
      @user = FactoryGirl.create(:user)
    end

    it "should require a password" do
      expect(@user.update_attributes(:password => "", :password_confirmation => "")).to eq false
    end

    it "should require a matching password confirmation" do
      expect(@user.update_attributes(:password_confirmation => "invalid")).to be_falsey
    end

    it "should reject short passwords" do
      short = "a" * 5
      hash = @user.update_attributes(:password => short, :password_confirmation => short)
      expect(User.new(hash)).to_not be_valid
    end
  end

  describe "password encryption" do

    before(:each) do
      @user = FactoryGirl.create(:user)
    end

    it "should have an encrypted password attribute" do
      expect(@user).to respond_to(:encrypted_password)
    end

    it "should set the encrypted password attribute" do
      expect(@user.encrypted_password).to be_truthy
    end
  end

# see user_mailer.rb : commented out while weaving in ActiveJob delayed_mail in upgrades
#describe "expire" do
#  around(:each) { ActionMailer::Base.deliveries.clear }
#  before(:each) do
#    @user = FactoryGirl.create(:user)
#  end

#  # commented it out while weaving in ActiveJob delayed_mail during upgrades
#  it "sends an email to user" do
#    @user.expire
#    expect(ActionMailer::Base.deliveries.last.to).to eq([@user.email])
#  end
#end

  describe "#update_plan" do
    before(:each) do
      @user = FactoryGirl.create(:user, email: "test@example.com")
      @role1 = FactoryGirl.create(:role, name: "silver")
      @role2 = FactoryGirl.create(:role, name: "gold")
      @user.add_role(@role1.name)
    end

    it "updates a users role" do
      expect(@user.roles.first.name).to eq("silver")
      @user.update_plan(@role2)
      expect(@user.roles.first.name).to eq("gold")
    end

    it "wont remove original role from database" do
      @user.update_plan(@role2)
      expect(Role.all.count).to eq(2)
    end
  end

end
