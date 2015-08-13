require 'stripe_mock'

include Warden::Test::Helpers
Warden.test_mode!

describe 'StripeToken' do

  let(:stripe_helper) { StripeMock.create_test_helper }

  before(:each) do
    StripeMock.start
  end

  after(:each) do
    StripeMock.stop
    Warden.test_reset!
  end
    
  describe 'Direct Token Creation' do
    it "generates and reads a card token for create charge" do
      card_token = stripe_helper.generate_card_token(last4: "4242", exp_month: 9, exp_year: 2019)
      card_charge = Stripe::Charge.create(amount: 500, currency: 'usd', source: card_token)
      charge = Stripe::Charge.retrieve(card_charge.id)
      expect(charge.source.last4).to eq "4242"
      expect(charge.source.exp_month).to eq 9
      expect(charge.source.exp_year).to eq 2019
    end

    it "generates and reads a card token for create customer" do
      card_token = stripe_helper.generate_card_token(last4: "4242", exp_month: 10, exp_year: 2020)
      customer = Stripe::Customer.create(source: card_token)
      card = customer.sources.data.first
      expect(card.last4).to eq "4242"
      expect(card.exp_month).to eq 10
      expect(card.exp_year).to eq 2020
    end

    it "generates and reads a card token for create customer" do
      card_token = stripe_helper.generate_card_token(card_number: "4242424242424242", exp_month: 11, exp_year: 2021)
      customer = Stripe::Customer.create(source: card_token)
      card = customer.sources.data.first
      expect(card.last4).to eq "4242"
      expect(card.exp_month).to eq 11
      expect(card.exp_year).to eq 2021
    end

    it "generates and reads a card token for update customer" do
      card_token = stripe_helper.generate_card_token(card_number: "4242424242424242", exp_month: 12, exp_year: 2022)
      customer = Stripe::Customer.create(source: card_token)
      customer.card = card_token
      customer.save
      card = customer.sources.data.first
      expect(card.last4).to eq "4242"
      expect(card.exp_month).to eq 12
      expect(card.exp_year).to eq 2022
    end
      
    it "generates and reads a card token for update customer" do
      card_token = stripe_helper.generate_card_token(last4: "1133", exp_month: 1, exp_year: 2023)
      customer = Stripe::Customer.create(source: card_token)
      customer.card = card_token
      customer.save
      card = customer.sources.data.first
      expect(card.last4).to eq "1133"
      expect(card.exp_month).to eq 1
      expect(card.exp_year).to eq 2023
    end

    it "retrieves a created token" do
      card_token = stripe_helper.generate_card_token(last4: "2323", exp_month: 2, exp_year: 2024)
      token = Stripe::Token.retrieve(card_token)
      expect(token.id).to eq(card_token)
      expect(token.card.last4).to eq "2323"
      expect(token.card.exp_month).to eq 2
      expect(token.card.exp_year).to eq 2024
    end
  end

  describe 'Stripe::Token' do
    it "generates a card token created from customer" do
      card_token = stripe_helper.generate_card_token({
        source: {
          card_number: "4242424242424242",
          exp_month: 11,
          exp_year: 2019,
        }
      })
      customer = Stripe::Customer.create(source: card_token)
      expect(customer.default_source).to match /^test_cc/
      customer.description = "a StripeMock card from customer"
      customer.save
      expect(card_token).to match /^test_tok/
      expect(customer.email).to eq "stripe_mock@example.com"
      expect(customer.description).to eq "a StripeMock card from customer"
      expect(customer.id).to match /^test_cus/
      expect(customer.object).to match /customer/
      expect(customer.livemode).to eq false
      expect(customer.discount).to eq nil
      expect(customer.default_source).to match /^test_cc/
    end

    it 'generates a stripe card token' do
      card_token = StripeMock.generate_card_token(last4: '9191', exp_month: 12, exp_year: 2025)
      cus = Stripe::Customer.create(source: card_token)
      user = Stripe::Customer.retrieve(cus.id)
      card = user.sources.data.first
      expect(card.last4).to eq '9191'
      expect(card.exp_month).to eq 12
      expect(card.exp_year).to eq 2025
      expect(user.sources.data.first.id).to match /^test_cc/
    end
  end
        
  describe "error handling" do
    it "throws an error if neither card nor customer are provided", live: true do
      expect{ Stripe::Token.create }.to raise_error(Stripe::InvalidRequestError, /must supply either a card, customer/)
    end
  end
end