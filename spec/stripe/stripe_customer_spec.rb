require 'stripe_mock'

include Warden::Test::Helpers
Warden.test_mode!

describe 'Customer API' do

  let(:stripe_helper) { StripeMock.create_test_helper }

  before(:each) do
    StripeMock.start
  end

  after(:each) do
    StripeMock.stop
    Warden.test_reset!
  end

  it "creates a stripe customer with a default source" do
    card_token = StripeMock.generate_card_token(last4: "1123", exp_month: 9, exp_year: 2016)
    customer = Stripe::Customer.create(
      email: 'user@example.com',
      source: card_token,
      description: "a customer description",
    )
    charge = Stripe::Charge.create({
      amount: 900,
      currency: "usd",
      interval: 'month',
      source: stripe_helper.generate_card_token(last4: "1123", exp_month: 10, exp_year: 2017),
      description: "Charge for user@example.com",
      }, {
        idempotency_key: "95ea4310438306ch"
    })
    card = customer.sources.data.first
    charge = Stripe::Charge.retrieve(charge.id)
    customer = Stripe::Customer.retrieve(customer.id)
    customer.sources { include[]=total_count }
    expect(card.id).to match /^test_cc/
    expect(charge.id).to match /^test_ch/
    expect(customer.id).to match /^test_cus/
    expect(customer.email).to eq 'user@example.com'
    expect(customer.description).to eq 'a customer description'
    expect(customer.sources.count).to eq 1
    expect(customer.sources.count).to eq 1
    expect(customer.sources.total_count).to eq 1
    expect(customer.sources.data.length).to eq 1
    expect(customer.sources.data.first).not_to be_nil
    expect(customer.sources.data.first.id).to match /^test_cc/
    expect(customer.default_source).not_to be_nil
    expect(customer.default_source).to eq customer.sources.data.first.id
    expect { customer.card }.to raise_error(NoMethodError, /card/) 
  end

  it "creates a stripe customer without a card" do
    customer = Stripe::Customer.create(
     email: 'cardless@example.com',
     description: "no card"
    )
    expect(customer.id).to match(/^test_cus/)
    expect(customer.email).to eq('cardless@example.com')
    expect(customer.description).to eq 'no card'
    expect(customer.sources.count).to eq 0
    expect(customer.sources.data.length).to eq 0
    expect(customer.default_source).to be_nil
  end
    
  it "stores a created stripe customer in memory" do
    customer = Stripe::Customer.create(
     email: 'storedinmemory@example.com',
     source: stripe_helper.generate_card_token,
    )
    customer2 = Stripe::Customer.create(
     email: 'bob@example.com',
     source: stripe_helper.generate_card_token,
    )
    customers = Stripe::Customer.all
    array = customers.to_a
    data = array.pop
    expect(customer.id).to match(/^test_cus/)
    expect(data.email).to eq 'bob@example.com'
    data2 = array.pop
    expect(data2.id).not_to be_nil
    expect(data2.email).to eq 'storedinmemory@example.com'
  end

  it "retrieves an identified stripe customer" do
    original = Stripe::Customer.create(
     email: 'retrievesidentifiedcustomer@example.com',
     source: stripe_helper.generate_card_token,
    )
    customer = Stripe::Customer.retrieve(original.id)
    expect(customer.id).to eq original.id
    expect(customer.email).to eq original.email
    expect(customer.default_source).to eq original.default_source
    expect(customer.subscriptions.count).to eq 0
    expect(customer.subscriptions.data).to be_empty
  end

  it "cannot retrieve a customer that doesn't exist" do
    expect { Stripe::Customer.retrieve('nope') }.to raise_error { |e|
      expect(e).to be_a Stripe::InvalidRequestError
      expect(e.param).to eq 'customer'
      expect(e.http_status).to eq 404
    }
  end

  it "retrieves all customers" do
    StripeMock.start
    all = Stripe::Customer.all
    Stripe::Customer.create({ email: 'one@example.com' })
    Stripe::Customer.create({ email: 'two@example.com' })
    allnow = Stripe::Customer.all
    expect(allnow.count).to eq(all.count + 2)
  end

  it "updates a stripe customer" do
    customer = Stripe::Customer.create(email: "updatecustomer@example.com")
    customer = Stripe::Customer.retrieve(customer.id)
    customer.email = "updatedcustomer@example.com"
    customer.save
    email = customer.email
    customer.description = 'new desc'
    customer.save
    expect(customer.email).to eq 'updatedcustomer@example.com'
    expect(customer.description).to eq 'new desc'
  end

  it "updates a stripe customer's card" do
    card_one = stripe_helper.generate_card_token(last4: "4242", exp_month: 11, exp_year: 2018)
    customer = Stripe::Customer.create(
      id: 'test_customer_update', 
      source: card_one,
    )
    card_one = customer.sources.data.first
    expect(card_one.id).to match(/^test_cc/)
    expect(customer.default_source).to match(/^test_cc/)
    expect(customer.default_source).to eq card_one.id
    expect(customer.sources.count).to eq 1
    customer.card = stripe_helper.generate_card_token(last4: "5555", exp_month: 12, exp_year: 2019)
    customer.save
    new_card = customer.sources.data.first
    expect(customer.sources.total_count).to eq 1
    expect(customer.default_source).to eq new_card.id
  end

  it "deletes a customer" do
    customer = Stripe::Customer.create(
      email: 'deleteme@example.com',
      source: stripe_helper.generate_card_token,
    )
    customer = Stripe::Customer.retrieve(customer.id)
    customer = customer.delete
    expect(customer.deleted).to eq true
  end
end