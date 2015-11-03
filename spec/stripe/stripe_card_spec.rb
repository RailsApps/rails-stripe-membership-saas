require 'stripe_mock'
include Warden::Test::Helpers
Warden.test_mode!

describe 'Card API', live: true do
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
    card_token = stripe_helper.generate_card_token(
      last4: '1123',
      exp_month: 12,
      exp_year: 2018
    )
    card = customer.sources.create(source: card_token)
    expect(card.customer).to eq('test_customer_sub')
    expect(card.last4).to eq '1123'
    expect(card.exp_month).to eq 12
    expect(card.exp_year).to eq 2018
    expect(customer.id).to match(/^test_cus/)
    expect(customer.email).to eq 'stripe_mock@example.com'
    expect(customer.description).to eq 'an auto-generated stripe customer data mock'

    customer = Stripe::Customer.retrieve('test_customer_sub')
    expect(customer.sources.count).to eq 1
    expect(customer.sources.data[0].id).to match(/^test_cc/)
    expect(customer.sources.data[0].last4).to eq '1123'
    expect(customer.sources.data[0].exp_month).to eq 12
    expect(customer.sources.data[0].exp_year).to eq 2018

    card = customer.sources.data.first
    expect(card.customer).to eq 'test_customer_sub'
    expect(card.last4).to eq '1123'
    expect(card.exp_month).to eq 12
    expect(card.exp_year).to eq 2018
  end

  it 'creates/returns a card when using customer.sources.create given a card token' do
    customer = Stripe::Customer.create(id: 'test_customer_sub')
    card_token = stripe_helper.generate_card_token(
      last4: '1123',
      exp_month: 11,
      exp_year: 2019
    )
    card = customer.sources.create(source: card_token)
    expect(card.customer).to eq 'test_customer_sub'
    expect(card.last4).to eq '1123'
    expect(card.exp_month).to eq 11
    expect(card.exp_year).to eq 2019

    customer = Stripe::Customer.retrieve('test_customer_sub')
    expect(customer.sources.count).to eq 1
    card = customer.sources.data.first
    expect(card.customer).to eq 'test_customer_sub'
    expect(card.last4).to eq '1123'
    expect(card.exp_month).to eq 11
    expect(card.exp_year).to eq 2019
  end

  it 'creates a single card with a generated card token' do
    customer = Stripe::Customer.create
    expect(customer.sources.count).to eq 0

    customer.sources.create(source: stripe_helper.generate_card_token)
    # Yes, stripe-ruby-mock does not actually add the new card to the customer instance
    expect(customer.sources.count).to eq 0

    customer2 = Stripe::Customer.retrieve(customer.id)
    expect(customer2.sources.count).to eq 1
    expect(customer2.default_source).to eq customer2.sources.first.id
  end

  it 'create does not change the customers default source if already set' do
    customer = Stripe::Customer.create(
      id: 'test_customer_sub',
      default_source: 'test_cc_original'
    )
    card_token = stripe_helper.generate_card_token(
      last4: '1123',
      exp_month: 7,
      exp_year: 2017
    )
    expect(card_token).to match(/^test_tok/)

    customer = Stripe::Customer.retrieve('test_customer_sub')
    expect(customer.sources.total_count).to eq 0
    expect(customer.subscriptions.total_count).to eq 0
    expect(customer.sources.data).to be_empty
    expect(customer.default_source).to match(/^test_cc_original/)

    card_token2 = stripe_helper.generate_card_token(
      last4: '4242',
      exp_month: 8,
      exp_year: 2028
    )
    expect(card_token2).to match(/^test_tok/)

    customer.sources.create(source: card_token2)
    customer = Stripe::Customer.retrieve('test_customer_sub')
    expect(customer.sources.data[0].id).to match(/^test_cc/)
    expect(customer.default_source).to eq 'test_cc_original'
  end

  it 'create updates the customers newest default source' do
    customer = Stripe::Customer.create(email: 'defaultsource@example.com')
    expect(customer.default_source).to eq nil

    card_token = stripe_helper.generate_card_token(
      last4: '4242',
      exp_month: 12,
      exp_year: 2026
    )
    card = customer.sources.create(source: card_token)
    customer = Stripe::Customer.retrieve(customer.id)
    expect(customer.default_source).to match(/^test_cc/)
  end

  it 'create updates the customers default source if not set' do
    customer = Stripe::Customer.create(
      id: 'test_customer_sub',
      default_source: 'test_cc_original'
    )
    expect(customer.default_source).to match(/^test_cc_original/)
    card_token = stripe_helper.generate_card_token(
      last4: '1123',
      exp_month: 8,
      exp_year: 2018
    )
    card = customer.sources.create(source: card_token)
    expect(card.id == 'test_cc_original').to eq false

    customer = Stripe::Customer.retrieve('test_customer_sub')
    expect(customer.sources.data[0].id).to match(/^test_cc/)
    expect(customer.default_source).to eq 'test_cc_original'
  end

  describe 'retrieval and deletion with customer' do
    let!(:customer) { Stripe::Customer.create(id: 'test_customer_sub') }
    let!(:card_token) { stripe_helper.generate_card_token(last4: '1123', exp_month: 11, exp_year: 2025) }
    let!(:card) { customer.sources.create(source: card_token) }

    it 'can retrieve all customers cards' do
      retrieved = customer.sources.all
      expect(retrieved.count).to eq 1
    end

    it 'retrieves a customer card' do
      retrieved = customer.sources.retrieve(card.id)
      expect(retrieved.to_s).to eq card.to_s
    end

    it 'retrieves a customer card after re-fetching the customer' do
      retrieved = Stripe::Customer.retrieve(customer.id).sources.retrieve(card.id)
      expect(retrieved.id).to eq card.id
    end

    it 'deletes a customer card' do
      card.delete
      retrieved_cus = Stripe::Customer.retrieve(customer.id)
      expect(retrieved_cus.sources.data).to be_empty
    end

    it 'deletes a customer card then set the default_source to nil' do
      card.delete
      retrieved_cus = Stripe::Customer.retrieve(customer.id)
      expect(retrieved_cus.default_source).to be_nil
    end

    it 'updates the default card if deleted' do
      card.delete
      retrieved_cus = Stripe::Customer.retrieve(customer.id)
      expect(retrieved_cus.default_source).to be_nil
    end
  end

  context 'deletion when the user has two sources' do
    let!(:card_token) { stripe_helper.generate_card_token(last4: '1123', exp_month: 12, exp_year: 2024) }
    let!(:card) { customer.sources.create(source: card_token) }
    let!(:card_token_2) { stripe_helper.generate_card_token(last4: '1123', exp_month: 12, exp_year: 2025) }
    let!(:card_2) { customer.sources.create(source: card_token_2) }
    let!(:customer) { Stripe::Customer.create(id: 'test_customer_sub', default_source: 'test_cc_original') }

    it 'has just one card anymore' do
      card.delete
      retrieved_cus = Stripe::Customer.retrieve(customer.id)
      expect(retrieved_cus.sources.data.count).to eq 1
      expect(retrieved_cus.sources.data.first.id).to eq card_2.id
    end

    it 'has just one card after a card deletion' do
      customer = Stripe::Customer.create
      card_token = stripe_helper.generate_card_token(
        last4: '1123',
        exp_month: 12,
        exp_year: 2026
      )
      card = customer.sources.create(source: card_token)
      card_token_2 = stripe_helper.generate_card_token(
        last4: '1124',
        exp_month: 12,
        exp_year: 2027
      )
      card_2 = customer.sources.create(source: card_token_2)
      customer.sources.retrieve(card_2.id).delete
      retrieved_cus = Stripe::Customer.retrieve(customer.id).sources.all(object: 'card')
      expect(retrieved_cus.data.count).to eq 1
      expect(retrieved_cus.data.first.id).to eq card.id
    end

    it 'sets the default_source id to the last card remaining id' do
      customer = Stripe::Customer.create
      card_token = stripe_helper.generate_card_token(
        last4: '1123',
        exp_month: 12,
        exp_year: 2028
      )
      card = customer.sources.create(source: card_token)
      customer = Stripe::Customer.retrieve(customer.id)
      card_token_2 = stripe_helper.generate_card_token(
        last4: '1124',
        exp_month: 12,
        exp_year: 2029
      )
      card_2 = customer.sources.create(source: card_token_2)
      customer = Stripe::Customer.retrieve(customer.id).sources.all(object: 'card')
      list = customer.data
      expect(list.first.id).to eq card.id
    end
  end

  describe 'Errors' do
    it 'throws an error when the customer does not have the retrieving card id' do
      customer = Stripe::Customer.create
      card_id = 'card_123'
      expect { customer.sources.retrieve(card_id) }.to raise_error { |e|
        expect(e).to be_a Stripe::InvalidRequestError
        expect(e.message).to include 'no source', card_id
        expect(e.param).to eq 'id'
        expect(e.http_status).to eq 404
      }
    end
  end

  context 'update card' do
    let!(:customer) { Stripe::Customer.create(id: 'test_customer_sub') }
    let!(:card_token) { stripe_helper.generate_card_token(last4: '1123', exp_month: 11, exp_year: 2025) }
    let!(:card) { customer.sources.create(source: card_token) }

    it 'updates the card' do
      exp_month = 12
      exp_year = 2028

      card.exp_month = exp_month
      card.exp_year = exp_year
      card.save

      retrieved = customer.sources.retrieve(card.id)

      expect(retrieved.exp_month).to eq(exp_month)
      expect(retrieved.exp_year).to eq(exp_year)
    end

    it 'updates the card differently' do
      customer = Stripe::Customer.create
      card_token = stripe_helper.generate_card_token(
        last4: '4242',
        exp_month: 12,
        exp_year: 2030
      )
      card = customer.sources.create(source: card_token)
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

  context 'retrieve multiple cards' do
    it 'retrieves a list of multiple cards' do
      customer = Stripe::Customer.create(id: 'test_customer_card')
      card_token = stripe_helper.generate_card_token(
        last4: '1123',
        exp_month: 12,
        exp_year: 2032
      )
      card1 = customer.sources.create(source: card_token)
      card_token = stripe_helper.generate_card_token(
        last4: '4242',
        exp_month: 12,
        exp_year: 2033
      )
      card2 = customer.sources.create(source: card_token)
      customer = Stripe::Customer.retrieve('test_customer_card')
      list = customer.sources.all
      expect(list.object).to eq 'list'
      expect(list.count).to eq 2
      expect(list.data.length).to eq 2
      expect(list.data.first.object).to eq 'card'
      expect(list.data.first.to_hash).to eq card1.to_hash
      expect(list.data.last.object).to eq 'card'
      expect(list.data.last.to_hash).to eq card2.to_hash
    end

    it 'retrieves an empty list if there are no subscriptions' do
      Stripe::Customer.create(id: 'no_cards')
      customer = Stripe::Customer.retrieve('no_cards')
      list = customer.sources.all
      expect(list.object).to eq 'list'
      expect(list.count).to eq 0
      expect(list.data.length).to eq 0
    end
  end

  describe 'prevents customer from deleting their default_source' do
    pending 'code is yet to be written'
    # Stripe API [Note that for cards belonging to customers, you may want to prevent customers
    # on paid subscriptions from deleting all cards on file so that there is at least one default
    # card for the next invoice payment attempt.]
    # I should rewrite this test accordingly.
    # Referenece : https://stripe.com/docs/api/ruby#delete_card
  end
end
