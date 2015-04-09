require 'rails_helper'
require 'stripe_mock'

include Warden::Test::Helpers
Warden.test_mode!

describe 'StripeToken' do

  let(:stripe_helper) { StripeMock.create_test_helper }

  after(:each) do
    Warden.test_reset!
  end

  StripeMock.toggle_debug(true)

  describe 'Direct Token Creation' do
    it "generates and reads a card token for create charge" do
      StripeMock.start
      card_token = Stripe::Token.create(
        card: {
        number: "4222222222222222",
        exp_month: 9,
        exp_year: 2017
        }
      )
      charge = Stripe::Charge.create(amount: 500, exp_month: 3, currency: 'usd', card: card_token)
      card = charge.card
      StripeMock.stop
    end

    it "generates and reads a card token for create customer" do
      StripeMock.start
      card_token = Stripe::Token.create(
        card: {
        number: "4222222222222222",
        exp_month: 9,
        exp_year: 2018
        }
      )
      cus = Stripe::Customer.create(card: card_token)
      card = cus.sources.data.first
      StripeMock.stop
    end

    it "generates and reads a card token for create customer" do
      StripeMock.start
      card_token = stripe_helper.generate_card_token(
        card: {
        number: "424242424242424242",
        exp_month: 9,
        exp_year: 2019,
        }
      )
      cus = Stripe::Customer.create(source: card_token)
      card = cus.sources.data.first
      StripeMock.stop
    end

    it "generates and reads a card token for update customer" do
      StripeMock.start
      card_token = Stripe::Token.create(
        card: {
        number: "4222222222222222",
        exp_month: 9,
        exp_year: 2020
        }
      )
      cus = Stripe::Customer.create()
      cus.card = card_token
      cus.save
      card = cus.sources.data.first
      StripeMock.stop
    end
  end

  describe 'Stripe::Token' do
      it "generates and reads a card token for update customer" do
      StripeMock.start
      card_token = Stripe::Token.create(
        card: {
        number: "4222222222222222",
        exp_month: 9,
        exp_year: 2021
        }
      )
      cus = Stripe::Customer.create(source: card_token.id)
      cus.card = card_token
      cus.save
      card = cus.sources.data.first
      StripeMock.stop
    end

    it "retrieves a created token" do
      StripeMock.start
        card_token = Stripe::Token.create(
        card: {
        number: "4222222222222222",
        exp_month: 9,
        exp_year: 2022
        }
      )
      token = Stripe::Token.retrieve(card_token.id)
      expect(token.id).to eq(card_token.id)
      StripeMock.stop
    end
  end

  describe 'Stripe::Token' do
    it "generates a card token created from customer" do
      StripeMock.start
      card_token = Stripe::Token.create(
        card: {
        number: "4242424242424242",
        exp_month: 9, 
        exp_year: 2023, 
      })
      customer = Stripe::Customer.create()
      customer.source = card_token.id
      customer.description = "a StripeMock card from customer"
      customer.save
      card_token = Stripe::Token.create(customer: customer.id)
      expect(card_token.object).to eq("token")
      expect(customer.email).to eq "stripe_mock@example.com"
      expect(customer.description).to eq "a StripeMock card from customer"
      expect(customer.id).to match(/^test_cus/)
      expect(customer.object).to match(/customer/)
      expect(customer.livemode).to eq false
      expect(customer.discount).to eq(nil)
      StripeMock.stop
    end
  end

  describe "error handling" do
    it "throws an error if neither card nor customer are provided", :live => true do
      expect { Stripe::Token.create }.to raise_error(Stripe::InvalidRequestError, /must supply either a card, customer/)
    end
  end
    
end
