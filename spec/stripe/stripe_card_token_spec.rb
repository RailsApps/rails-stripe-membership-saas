require 'stripe_mock'
require 'pry'
include Warden::Test::Helpers
Warden.test_mode!

describe 'StripeToken' do

  let(:stripe_helper) { StripeMock.create_test_helper }

  after(:each) do
    Warden.test_reset!
  end
    
  describe 'Direct Token Creation' do
    it "generates and reads a card token for create charge" do
      StripeMock.start
#binding.pry
      card_token = StripeMock.generate_card_token(last4: 4242, exp_month: 12, exp_year: 2055)
      token = Stripe::Token.retrieve(card_token)
      expect(token.livemode).to eq false
      expect(token.used).to eq false
      expect(token.type).to eq 'card'
      expect(token.object).to eq 'token'
      expect(token.card[:id]).to match /^test_cc_.+/
      expect(token.card[:object]).to eq 'card'
    #  expect(token.card[:last4]).to match /^test_tok_.+/
      expect(token.card[:type]).to eq 'Visa'
      expect(token.card[:funding]).to eq 'credit'
      expect(token.card[:exp_month]).to eq 12
      expect(token.card[:exp_year]).to eq 2055
      expect(token.card[:customer]).to match /^test_cus_.*/
      expect(token.card[:cvc_check]).to eq nil
      expect(token.card[:number]).to eq nil
      charge = Stripe::Charge.create({amount: 500, currency: :'usd', source: card_token, description: 'Charge for test@example.com'
      }, {
        idempotency_key: 9876543210
      })
      expect(charge).to match /^test_ch_.+/
      StripeMock.stop
    end

    it "generates and reads a card token for create customer" do
      StripeMock.start
      card_token = StripeMock.generate_card_token(last4: 4242, exp_month: 12, exp_year: 2055)
      customer = Stripe::Customer.create(card: card_token)
      customer = Stripe::Customer.retrieve(customer.id)
      expect(customer.sources.url).to match /test_cus_.+/
      expect(customer.email).to eq 'stripe_mock@example.com'
      expect(customer.description).to eq 'an auto-generated stripe customer data mock'
      expect(customer.sources.object).to eq 'list'
      expect(customer.sources.total_count).to eq 0
      expect(customer.sources.url).to match /test_cus_.+/
      expect(customer.sources.data).to eq []
      expect(customer.default_source).to eq nil
      expect(customer.card).to match /test_tok/ 
      StripeMock.stop
    end

    it "generates and reads a card token for update customer" do
      StripeMock.start
      card_token = StripeMock.generate_card_token(card_number: 4242424242424242, exp_month: 11, exp_year: 2055)
      customer = Stripe::Customer.create()
      customer = Stripe::Customer.retrieve(customer.id)
      customer.card = card_token
      customer.save
      card = Stripe::Customer.retrieve(customer.id).card
      expect(card).to match /^test_tok_.+/
      StripeMock.stop
    end
      
    it "generates and reads a card token for update customer" do
      StripeMock.start
      card_token = StripeMock.generate_card_token(last4: 4242, exp_month: 12, exp_year: 2055)
      customer = Stripe::Customer.create()
      customer = Stripe::Customer.retrieve(customer.id)
      customer.card = card_token
      customer.save
      card = Stripe::Customer.retrieve(customer.id).card
      expect(card).to match /^test_tok_.+/
      StripeMock.stop
    end

    it "retrieves a created token" do
      StripeMock.start
      card_token = StripeMock.generate_card_token(last4: 2323, exp_month: 33, exp_year: 2222)
      token = Stripe::Token.retrieve(card_token)
      expect(token.id).to eq(card_token)
    #  expect(token.card.last4).to eq 2323
      expect(token.card.exp_month).to eq 33
      expect(token.card.exp_year).to eq 2222
      StripeMock.stop
    end
  end

  describe 'Stripe::Token' do
    it "generates a card token created from customer" do
      StripeMock.start
      card_token = Stripe::Token.create({
        card: {
        number: "4242424242424242",
        exp_month: 11,
        exp_year: 2019,
      }
    })
    customer = Stripe::Customer.create()
    customer.card = card_token.id
    customer.description = "a StripeMock card from customer"
    customer.save
    expect(card_token.id).to match(/test_tok_.+/)
    expect(customer.email).to eq "stripe_mock@example.com"
    expect(customer.description).to eq "a StripeMock card from customer"
    expect(customer.id).to match(/^test_cus_.+/)
    expect(customer.object).to match(/customer/)
    expect(customer.livemode).to eq false
    expect(customer.discount).to eq(nil)
    expect(customer.default_source).to eq nil
    expect(customer.card).to match(/^test_tok_.+/)
    expect(card_token.id).to match(/^test_tok_.+/)
    StripeMock.stop
    end
  end

        
  describe "error handling" do
    it "throws an error if neither card nor customer are provided", :live => true do
       StripeMock.start
       expect{ Stripe::Token.create }.to raise_error(Stripe::InvalidRequestError, /must supply either a card, customer/)
      StripeMock.stop
    end
  end
end