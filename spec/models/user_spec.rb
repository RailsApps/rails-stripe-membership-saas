require 'rails_helper'
require 'stripe_mock'
require 'stripe_mock/server'

include Warden::Test::Helpers
Warden.test_mode!

RSpec.configure do

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

  before(:each) { @user = User.new(email: 'user@example.com') }

  subject { @user }

  it { should respond_to(:email) }

#  it "should respond to email" do
 #   StripeMock.start
  #  expect(respond_to(:email).to be_success
   # StripeMock.stop
  #end

  it "#email returns a string" do
    StripeMock.start
    expect(@user.email).to match 'user@example.com'
    StripeMock.stop
  end

  it "should have a password attribute" do
    StripeMock.start
    expect(@user).to respond_to(:password)
    StripeMock.stop
  end

  it "should have a password confirmation attribute" do
    StripeMock.start
    expect(@user).to respond_to(:password_confirmation)
    StripeMock.stop
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
        customer = Stripe::Customer.create({
          email: 'someone@example.com',
          card: stripe_helper.generate_card_token
        })
        expect(customer.email).to eq('someone@example.com')
      end

      it "creates a new user with a succesful stripe response" do
        customer = Stripe::Customer.create({
          email: 'example@example.com',
          card: stripe_helper.generate_card_token(:id => "silver", :amount => 900)
        })
        expect(customer.email).to eq('example@example.com')
        token = customer.card
        @user = FactoryGirl.build(:user, email: "example@example.com", password: 'changeme', password_confirmation: 'changeme')
        @user.role = "silver"
        @user.save
        expect(@user.role).to eq('silver')

        customer = Stripe::Customer.retrieve(customer.id)
        expect(customer.id).to match(/^test_cus/)
        expect(customer.card).to match(/^test_tok/)
        StripeMock.stop
      end

      it "should create a new instance given a valid attribute" do
        StripeMock.start
        email_user = FactoryGirl.create(:user, :email => "instance@example.com")
        email_user.update_attributes(:email => "user@example.com")
        expect(email_user.email.nil?).to be_falsey
        StripeMock.stop
      end

      it "should require an email address" do
        StripeMock.start
        no_email_user = FactoryGirl.create(:user, :email => "noemail@example.com")
        no_email_user.update_attributes(:email => "")
        expect(no_email_user.email.nil?).to be_falsey
        StripeMock.stop
      end

      it "should accept valid email addresses" do
        StripeMock.start
        customer = Stripe::Customer.create({
          email: 'example@example.com',
          card: stripe_helper.generate_card_token(:id => "silver", :amount => 900)
        })
        @token = customer.card
        addresses = %w[user@foo.com THE_USER@foo.bar.org first.last@foo.jp]
        addresses.each do |address|
        valid_email_user = FactoryGirl.build(:user)
        valid_email_user.update_attributes(email: "example@example.com", password: 'changeme', password_confirmation: 'changeme')
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
        user = FactoryGirl.create(:user, :email => "duplicate@example.com")
        user2 = FactoryGirl.build(:user, :email => "duplicate@example.com")
        expect(user2).to be_invalid
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
      @user = FactoryGirl.build(:user)
    end

    it "should require a password" do
      StripeMock.start
      expect(@user.update_attributes(:password => "", :password_confirmation => "")).to eq false
      StripeMock.stop
    end

    it "should require a matching password confirmation" do
      StripeMock.start
      expect(@user.update_attributes(:password_confirmation => "invalid")).to be_falsey
      StripeMock.stop
    end

    it "should reject short passwords" do
      StripeMock.start
      short = "a" * 5
      hash = @user.update_attributes(:password => short, :password_confirmation => short)
      expect(User.new(hash)).to_not be_valid
      StripeMock.stop
    end
  end

  describe "password encryption" do

    before(:each) do
      @user = FactoryGirl.build(:user)
    end

    it "should have an encrypted password attribute" do
      StripeMock.start
      expect(@user).to respond_to(:encrypted_password)
      StripeMock.stop
    end

    it "should set the encrypted password attribute" do
      StripeMock.start
      expect(@user.encrypted_password).to be_truthy
      StripeMock.stop
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
      @user = FactoryGirl.build(:user)
      @role1 = 'silver'
      @role2 = 'gold'
      @user.role = @role1
    end

    it "updates a users role" do
      StripeMock.start
      expect(@user.role).to eq("silver")
      @user.update_attributes(:role => @role2)
      expect(@user.role).to eq("gold")
      StripeMock.stop
    end
  end

end