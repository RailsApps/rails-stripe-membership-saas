require 'rails_helper'
require 'stripe_mock'

include Warden::Test::Helpers
Warden.test_mode!

describe 'Card API' do
    let(:stripe_helper) { StripeMock.create_test_helper }

    after(:each) do
      Warden.test_reset!
    end

  it 'creates/returns a card when using customer.sources.create given a card token' do
    StripeMock.start
    customer = Stripe::Customer.create(id: 'test_customer_sub')
    card_token = StripeMock.generate_card_token(last4: "1123", exp_month: 11, exp_year: 2099)
    card = customer.sources.create(card: card_token)
    expect(card.customer).to eq('test_customer_sub')
    expect(card.last4).to eq("1123")
    expect(card.exp_month).to eq(11)
    expect(card.exp_year).to eq(2099)
    customer = Stripe::Customer.retrieve('test_customer_sub')
    customer.sources {include[]=total_count }
    expect(customer.sources.total_count).to eq(1)
    card = customer.sources.data.first
    expect(card.customer).to eq('test_customer_sub')
    expect(card.last4).to eq("1123")
    expect(card.exp_month).to eq(11)
    expect(card.exp_year).to eq(2099)
    StripeMock.stop
  end

  it 'creates/returns a card when using customer.sources.create given card params' do
    StripeMock.start
    customer = Stripe::Customer.create(id: 'test_customer_sub')
    card = customer.sources.create(card: {
      number: '4242424242424242',
      exp_month: '11',
      exp_year: '3031',
      cvc: '123'
    })
    expect(card.customer).to eq('test_customer_sub')
    expect(card.last4).to eq("4242")
    expect(card.exp_month).to eq(11)
    expect(card.exp_year).to eq(3031)
    customer = Stripe::Customer.retrieve('test_customer_sub')
    expect(customer.sources.count).to eq(1)
    card = customer.sources.data.first
    expect(card.customer).to eq('test_customer_sub')
    expect(card.last4).to eq("4242")
    expect(card.exp_month).to eq(11)
    expect(card.exp_year).to eq(3031)
    StripeMock.stop
  end

  it "creates a single card with a generated card token", :live => true do
   #pending "unfinished 20150406"
    StripeMock.start
    customer = Stripe::Customer.create
    customer = Stripe::Customer.create(id: 'test_customer_sub')
    card_token = stripe_helper.generate_card_token(last4: "1123", exp_month: 11, exp_year: 2019)
    expect(card_token).to match(/^test_tok/)
    StripeMock.stop
  end

  it 'create does not change the customers default card if already set' do
    StripeMock.start
    customer = Stripe::Customer.create(id: 'test_customer_sub')
    card_token = stripe_helper.generate_card_token(last4: "1123", exp_month: 11, exp_year: 2019)
    card = customer.sources.create(card: card_token)
    customer = Stripe::Customer.retrieve('test_customer_sub').sources.all(:object => "card")
    card = customer.data.first
    expect(card.id).to match(/^test_cc/)
    StripeMock.stop
  end

  it 'create updates the customers default card if not set' do
    StripeMock.start
    customer = Stripe::Customer.create(id: 'test_customer_sub', default_source: "test_cc_original")
    card_token = stripe_helper.generate_card_token(last4: "1123", exp_month: 11, exp_year: 2019)
    card = customer.sources.create(card: card_token)
    customer = Stripe::Customer.retrieve('test_customer_sub').sources.all(:object => "card")
    expect(customer.data.first).not_to be_nil
    StripeMock.stop
  end

  context "retrieval and deletion" do

    it "retrieves a customers card" do
      StripeMock.start
      customer = Stripe::Customer.create(id: 'test_customer_sub') #, default_source: "test_cc_2")
      card_token = StripeMock.generate_card_token(last4: "1123", exp_month: 11, exp_year: 2099)
      card = customer.sources.create(card: card_token)
      customer = Stripe::Customer.retrieve('test_customer_sub').sources.all(:object => "card")
      expect(customer.data.first.to_s).to eq(card.to_s)
      StripeMock.stop
    end
    
    it "retrieves a customer's card after re-fetching the customer" do
      StripeMock.start
      customer = Stripe::Customer.create(id: 'test_customer_sub', default_source: "test_cc_original")
      card_token = StripeMock.generate_card_token(last4: "1123", exp_month: 11, exp_year: 2019)
      card = customer.sources.create(card: card_token)
      retrieved = Stripe::Customer.retrieve(customer.id).sources.retrieve(card.id)
      expect(retrieved.id).to eq card.id
      StripeMock.stop
    end
    
    it "deletes a customers card" do
      StripeMock.start
      customer = Stripe::Customer.create(id: 'test_customer_sub', default_source: "test_cc_original")
      card_token = StripeMock.generate_card_token(last4: "1123", exp_month: 11, exp_year: 2019)
      card = customer.sources.create(card: card_token)
      card.delete
      retrieved_cus = Stripe::Customer.retrieve(customer.id)
      expect(retrieved_cus.sources.data).to be_empty
      StripeMock.stop
    end
    
    it "deletes a customers card then set the default_source to nil" do
      StripeMock.start
      customer = Stripe::Customer.create(id: 'test_customer_sub', default_source: "test_cc_original")
      card_token = StripeMock.generate_card_token(last4: "1123", exp_month: 11, exp_year: 2019)
      card = customer.sources.create(card: card_token)
      card.delete
      retrieved_cus = Stripe::Customer.retrieve(customer.id).sources.all(:object => "card")
      expect(retrieved_cus.data).to eq([])
      StripeMock.stop
    end
    
    it "updates the default card if deleted" do
      StripeMock.start
      customer = Stripe::Customer.create(id: 'test_customer_sub')
      card_token = stripe_helper.generate_card_token(last4: "1123", exp_month: 11, exp_year: 2019)
      card = customer.sources.create(card: card_token)
      card.delete
      retrieved_cus = Stripe::Customer.retrieve(customer.id).sources.all(:object => "card")
      expect(retrieved_cus.data).to eq([])
    end
  end
    
  context "deletion when the user has two cards" do
    let!(:card_token) { stripe_helper.generate_card_token(last4: "1123", exp_month: 11, exp_year: 2019) }
    let!(:card) { customer.sources.create(card: card_token) }
    let!(:card_token_2) { stripe_helper.generate_card_token(last4: "1124", exp_month: 12, exp_year: 2020) }
    let!(:card_2) { customer.sources.create(card: card_token_2) }
    TOKEN = ":card_token"
    let!(:customer) { Stripe::Customer.create(id: 'test_customer_sub', :token => 'TOKEN') }

    it "has just one card anymore" do
      customer = Stripe::Customer.create
      card_token = stripe_helper.generate_card_token(last4: "1123", exp_month: 11, exp_year: 2019)
      card = customer.sources.create(card: card_token)
      card_token_2 = stripe_helper.generate_card_token(last4: "1124", exp_month: 12, exp_year: 2020)
      card_2 = customer.sources.create(card: card_token_2)
      customer.sources.retrieve(card_2.id).delete()
      retrieved_cus = Stripe::Customer.retrieve(customer.id).sources.all(:object => "card")
      expect(retrieved_cus.data.count).to eq 1
      expect(retrieved_cus.data.first.id).to eq card.id
    end

    it "sets the default_source id to the last card remaining id" do
      StripeMock.start
      customer = Stripe::Customer.create
      card_token = stripe_helper.generate_card_token(last4: "1123", exp_month: 11, exp_year: 2019)
      card = customer.sources.create(card: card_token)
      customer = Stripe::Customer.retrieve(customer.id)
      card_token_2 = stripe_helper.generate_card_token(last4: "1124", exp_month: 12, exp_year: 2020)
      card_2 = customer.sources.create(card: card_token_2)
      customer = Stripe::Customer.retrieve(customer.id).sources.all(:object => "card")
      list = customer.data
      expect(list.first.id).to eq card.id
      StripeMock.stop
    end
  end

  describe "Errors", :live => true do
    it "throws an error when the customer does not have the retrieving card id" do
      StripeMock.start
      customer = Stripe::Customer.create
      card_token = stripe_helper.generate_card_token(last4: "1123", exp_month: 11, exp_year: 2019)
      card_id = "test_cc_123"
      expect { customer.sources.create(card: card_id) }.to raise_error {|e|
      expect(e).to be_a Stripe::InvalidRequestError
      expect(e.http_status).to eq 404
      }
      StripeMock.stop
    end
  end

  describe "update card" do
    it "updates the card" do
      StripeMock.start
      customer = Stripe::Customer.create()
      card_token = StripeMock.generate_card_token(last4: "1123", exp_month: 11, exp_year: 2019)
      card = customer.sources.create(card: card_token)
      exp_month = 10
      exp_year = 2020

      card.exp_month = exp_month
      card.exp_year = exp_year
      card.save

      retrieved = customer.sources.retrieve(card.id)
      expect(retrieved.exp_month).to eq(exp_month)
      expect(retrieved.exp_year).to eq(exp_year)
      StripeMock.stop
    end
  end
    
  describe "retrieve multiple cards" do
    it "retrieves a list of multiple cards" do
      StripeMock.start
      customer = Stripe::Customer.create(id: 'test_customer_card')
      card_token = StripeMock.generate_card_token(last4: "1123", exp_month: 11, exp_year: 2099)
      card1 = customer.sources.create(card: card_token)
      card_token = StripeMock.generate_card_token(last4: "1124", exp_month: 12, exp_year: 2098)
      card2 = customer.sources.create(card: card_token)
      customer = Stripe::Customer.retrieve('test_customer_card')
      list = customer.sources.all
      expect(list.object).to eq("list")
      expect(list.count).to eq(2)
      expect(list.data.length).to eq(2)
      expect(list.data.first.object).to eq("card")
      expect(list.data.first.to_hash).to eq(card1.to_hash)
      expect(list.data.last.object).to eq("card")
      expect(list.data.last.to_hash).to eq(card2.to_hash)
      StripeMock.stop
    end

    # Stripe API : "Note that for cards belonging to customers, you may want to prevent customers 
    # on paid subscriptions from deleting all cards on file so that there is at least one default
    # card for the next invoice payment attempt." If you do, rewrite this test accordingly.
    # Referenece : https://stripe.com/docs/api/ruby#delete_card 
    it "retrieves an empty list if there's no subscriptions" do
      StripeMock.start
      Stripe::Customer.create(id: 'no_cards')
      customer = Stripe::Customer.retrieve('no_cards')
      list = customer.sources.all
      expect(list.object).to eq("list")
      expect(list.count).to eq(0)
      expect(list.data.length).to eq(0)
      StripeMock.stop
    end
  end
    
end
