require 'stripe_mock'

include Warden::Test::Helpers
Warden.test_mode!

describe 'Card API' do

    let(:stripe_helper) { StripeMock.create_test_helper }

    before(:each) do
      StripeMock.start
    end

    after(:each) do
      StripeMock.stop
      Warden.test_reset!
    end

  it 'creates/returns a card when using customer.sources.create given a card token' do
    customer = Stripe::Customer.create(id: 'test_customer_sub')
    card_token = stripe_helper.generate_card_token(last4: "1123", exp_month: 12, exp_year: 2015)
    card = customer.sources.create(card: card_token)
    expect(card.customer).to eq 'test_customer_sub'
    expect(card.last4).to eq "1123"
    expect(card.exp_month).to eq 12
    expect(card.exp_year).to eq 2015

    customer = Stripe::Customer.retrieve('test_customer_sub')
    customer.sources { include[]=total_count }
    expect(customer.sources.total_count).to eq 1
    expect(card.customer).to eq 'test_customer_sub'
    expect(card.last4).to eq "1123"
    expect(card.exp_month).to eq 12
    expect(card.exp_year).to eq 2015
  end

  it 'creates/returns a card when using customer.sources.create given card params' do
    customer = Stripe::Customer.create(id: 'test_customer_sub')
    card = customer.sources.create(card: {
      number: '4242424242424242',
      exp_month: '6',
      exp_year: '2016',
      cvc: '123'
    })
    expect(card.customer).to eq 'test_customer_sub'
    expect(card.last4).to eq "4242"
    expect(card.exp_month).to eq 6
    expect(card.exp_year).to eq 2016

    customer = Stripe::Customer.retrieve('test_customer_sub')
    expect(customer.sources.count).to eq 1
    card = customer.sources.data.first
    expect(card.customer).to eq 'test_customer_sub'
    expect(card.last4).to eq "4242"
    expect(card.exp_month).to eq 6
    expect(card.exp_year).to eq 2016
  end

  it "creates a single card with a generated card token", live: true do
    customer = Stripe::Customer.create
    expect(customer.sources.count).to eq 0

    customer.sources.create( { card: stripe_helper.generate_card_token })
    # Yes, stripe-ruby-mock does not actually add the new card to the customer instance
    expect(customer.sources.count).to eq 0

    customer2 = Stripe::Customer.retrieve(customer.id)
    expect(customer2.sources.count).to eq 1
    expect(customer2.default_source).to eq customer2.sources.first.id
  end

  it 'create does not change the customers default card if already set' do
    customer = Stripe::Customer.create(id: 'test_customer_sub', default_source: "test_cc_original")
    card_token = stripe_helper.generate_card_token(last4: "1123", exp_month: 7, exp_year: 2017)
    card = customer.sources.create(card: card_token)
    customer = Stripe::Customer.retrieve('test_customer_sub')
    expect(customer.default_source).to eq "test_cc_original"
  end

  it 'create updates the customers default card if not set' do
    customer = Stripe::Customer.create(id: 'test_customer_sub', default_source: "test_cc_original")
    card_token = stripe_helper.generate_card_token(last4: "1123", exp_month: 8, exp_year: 2018)
    card = customer.sources.create(card: card_token)
    customer = Stripe::Customer.retrieve('test_customer_sub')
    expect(customer.default_source).not_to be_nil
  end

  context "retrieval and deletion" do

    it "retrieves a customers card" do
      customer = Stripe::Customer.create(id: 'test_customer_sub', default_source: "test_cc_original")
      card_token = stripe_helper.generate_card_token(last4: "1123", exp_month: 9, exp_year: 2019)
      card = customer.sources.create(card: card_token)
      retrieved = customer.sources.retrieve(card.id)
      expect(retrieved.to_s).to eq card.to_s
    end
    
    it "retrieves a customer's card after re-fetching the customer" do
      customer = Stripe::Customer.create(id: 'test_customer_sub', default_source: "test_cc_original")
      card_token = stripe_helper.generate_card_token(last4: "1123", exp_month: 10, exp_year: 2020)
      card = customer.sources.create(card: card_token)
      retrieved = Stripe::Customer.retrieve(customer.id).sources.retrieve(card.id)
      expect(retrieved.id).to eq card.id
    end
    
    it "deletes a customers card" do
      customer = Stripe::Customer.create(id: 'test_customer_sub', default_source: "test_cc_original")
      card_token = stripe_helper.generate_card_token(last4: "1123", exp_month: 11, exp_year: 2021)
      card = customer.sources.create(card: card_token)
      card.delete
      retrieved_cus = Stripe::Customer.retrieve(customer.id)
      expect(retrieved_cus.sources.data).to be_empty
    end
    
    it "deletes a customers card then set the default_source to nil" do
      customer = Stripe::Customer.create(id: 'test_customer_sub', default_source: "test_cc_original")
      card_token = stripe_helper.generate_card_token(last4: "1123", exp_month: 12, exp_year: 2022)
      card = customer.sources.create(card: card_token)
      card.delete
      retrieved_cus = Stripe::Customer.retrieve(customer.id)
      expect(retrieved_cus.default_source).to be_nil
    end
    
    it "updates the default card if deleted" do
      customer = Stripe::Customer.create(id: 'test_customer_sub', default_source: "test_cc_original")
      card_token = stripe_helper.generate_card_token(last4: "1123", exp_month: 12, exp_year: 2023)
      card = customer.sources.create(card: card_token)
      card.delete
      retrieved_cus = Stripe::Customer.retrieve(customer.id)
      expect(retrieved_cus.default_source).to be_nil
    end
  end
    
  context "deletion when the user has two sources" do

    let!(:card_token) { stripe_helper.generate_card_token(last4: "1123", exp_month: 12, exp_year: 2024) }
    let!(:card) { customer.sources.create(card: card_token) }
    let!(:card_token_2) { stripe_helper.generate_card_token(last4: "1123", exp_month: 12, exp_year: 2025) }
    let!(:card_2) { customer.sources.create(card: card_token_2) }
    let!(:customer) { Stripe::Customer.create(id: 'test_customer_sub', default_source: "test_cc_original") }

    it "has just one card anymore" do
      card.delete
      retrieved_cus = Stripe::Customer.retrieve(customer.id)
      expect(retrieved_cus.sources.data.count).to eq 1
      expect(retrieved_cus.sources.data.first.id).to eq card_2.id
    end

    # duplicate of above, testing both
    it "has just one card anymore" do
      customer = Stripe::Customer.create
      card_token = stripe_helper.generate_card_token(last4: "1123", exp_month: 12, exp_year: 2026)
      card = customer.sources.create(card: card_token)
      card_token_2 = stripe_helper.generate_card_token(last4: "1124", exp_month: 12, exp_year: 2027)
      card_2 = customer.sources.create(card: card_token_2)
      customer.sources.retrieve(card_2.id).delete()
      retrieved_cus = Stripe::Customer.retrieve(customer.id).sources.all(object: "card")
      expect(retrieved_cus.data.count).to eq 1
      expect(retrieved_cus.data.first.id).to eq card.id
    end

   it "sets the default_source id to the last card remaining id" do
      customer = Stripe::Customer.create
      card_token = stripe_helper.generate_card_token(last4: "1123", exp_month: 12, exp_year: 2028)
      card = customer.sources.create(card: card_token)
      customer = Stripe::Customer.retrieve(customer.id)
      card_token_2 = stripe_helper.generate_card_token(last4: "1124", exp_month: 12, exp_year: 2029)
      card_2 = customer.sources.create(card: card_token_2)
      customer = Stripe::Customer.retrieve(customer.id).sources.all(object: "card")
      list = customer.data
      expect(list.first.id).to eq card.id
    end
  end

  describe "Errors", live: true do
    it "throws an error when the customer does not have the retrieving card id" do
      customer = Stripe::Customer.create
      card_id = "card_123"
      expect { customer.sources.retrieve(card_id) }.to raise_error { |e|
        expect(e).to be_a Stripe::InvalidRequestError
        expect(e.message).to include "no source", card_id
        expect(e.param).to eq 'id'
        expect(e.http_status).to eq 404
      }
    end
  end

  describe "update card" do
    it "updates the card" do
      customer = Stripe::Customer.create()
      card_token = stripe_helper.generate_card_token(last4: "4242", exp_month: 12, exp_year: 2030)
      card = customer.sources.create(card: card_token)
      exp_month = 12
      exp_year = 2031
      card.exp_month = exp_month
      card.exp_year = exp_year
      card.save
      retrieved = customer.sources.retrieve(card.id)
      expect(retrieved.exp_month).to eq exp_month
      expect(retrieved.exp_year).to eq exp_year
    end
  end
    
  describe "retrieve multiple cards" do
    it "retrieves a list of multiple cards" do
      customer = Stripe::Customer.create(id: 'test_customer_card')
      card_token = stripe_helper.generate_card_token(last4: "1123", exp_month: 12, exp_year: 2032)
      card1 = customer.sources.create(card: card_token)
      card_token = stripe_helper.generate_card_token(last4: "1124", exp_month: 12, exp_year: 2033)
      card2 = customer.sources.create(card: card_token)
      customer = Stripe::Customer.retrieve('test_customer_card')
      list = customer.sources.all
      expect(list.object).to eq "list"
      expect(list.count).to eq 2
      expect(list.data.length).to eq 2
      expect(list.data.first.object).to eq "card" 
      expect(list.data.first.to_hash).to eq card1.to_hash
      expect(list.data.last.object).to eq "card"
      expect(list.data.last.to_hash).to eq card2.to_hash
    end

    it "retrieves an empty list if there's no subscriptions" do
      Stripe::Customer.create(id: 'no_cards')
      customer = Stripe::Customer.retrieve('no_cards')
      list = customer.sources.all
      expect(list.object).to eq "list"
      expect(list.count).to eq 0
      expect(list.data.length).to eq 0
    end
  end
end