require 'stripe_mock'

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
      card_token = StripeMock.generate_card_token(last4: "2244", exp_month: 33, exp_year: 2255)
      charge = Stripe::Charge.create(amount: 500, card: card_token)
      card = charge.card
      expect(card.last4).to eq("2244")
      expect(card.exp_month).to eq(33)
      expect(card.exp_year).to eq(2255)
      StripeMock.stop
    end

    it "generates and reads a card token for create customer" do
      StripeMock.start
      card_token = StripeMock.generate_card_token(last4: "9191", exp_month: 99, exp_year: 3005)
      cus = Stripe::Customer.create(card: card_token)
      card = cus.cards.data.first
      expect(card.last4).to eq("9191")
      expect(card.exp_month).to eq(99)
      expect(card.exp_year).to eq(3005)
      StripeMock.stop
    end

    it "generates and reads a card token for create customer" do
      StripeMock.start
      card_token = StripeMock.generate_card_token(number: "4242424242424242", exp_month: 2, exp_year: 2017)
      cus = Stripe::Customer.create(card: card_token)
      card = cus.cards.data.first
      expect(card.last4).to eq("4242")
      expect(card.exp_month).to eq(2)
      expect(card.exp_year).to eq(2017)
      StripeMock.stop
    end

    it "generates and reads a card token for update customer" do
      StripeMock.start
      card_token = StripeMock.generate_card_token(number: "4242424242424242", exp_month: 11, exp_year: 2019)
      cus = Stripe::Customer.create()
      cus.card = card_token
      cus.save
      card = cus.cards.data.first
      expect(card.last4).to eq("4242")
      expect(card.exp_month).to eq(11)
      expect(card.exp_year).to eq(2019)
      StripeMock.stop
    end
      
    it "generates and reads a card token for update customer" do
      StripeMock.start
      card_token = StripeMock.generate_card_token(last4: "1133", exp_month: 11, exp_year: 2099)
      cus = Stripe::Customer.create()
      cus.card = card_token
      cus.save
      card = cus.cards.data.first
      expect(card.last4).to eq("1133")
      expect(card.exp_month).to eq(11)
      expect(card.exp_year).to eq(2099)
      StripeMock.stop
    end

    it "retrieves a created token" do
      StripeMock.start
      card_token = StripeMock.generate_card_token(last4: "2323", exp_month: 33, exp_year: 2222)
      token = Stripe::Token.retrieve(card_token)
      expect(token.id).to eq(card_token)
      expect(token.card.last4).to eq("2323")
      expect(token.card.exp_month).to eq(33)
      expect(token.card.exp_year).to eq(2222)
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
    expect(card_token.id).to match(/test_tok_/)
    expect(customer.email).to eq "stripe_mock@example.com"
    expect(customer.description).to eq "a StripeMock card from customer"
    expect(customer.id).to match(/^test_cus/)
    expect(customer.object).to match(/customer/)
    expect(customer.livemode).to eq false
    expect(customer.discount).to eq(nil)
    expect(customer.default_card).to match(/test_cc_/)
    expect(card_token.id).to match(/^test_tok_/)
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