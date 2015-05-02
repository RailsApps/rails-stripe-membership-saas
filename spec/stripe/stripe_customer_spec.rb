require 'stripe_mock'

include Warden::Test::Helpers
Warden.test_mode!

describe 'Customer API' do
  let(:stripe_helper) { StripeMock.create_test_helper }

  after(:each) do
    Warden.test_reset!
  end

  it "creates a stripe customer with a default card" do
    StripeMock.start
    customer = Stripe::Customer.create({
      email: 'user@example.com',
      card: stripe_helper.generate_card_token,
      description: "a customer description"
    })
    expect(customer.id).to match(/^test_cus/)
    expect(customer.email).to eq('user@example.com')
    expect(customer.description).to eq('a customer description')
    expect(customer.cards.count).to eq(1)
    expect(customer.cards.data.length).to eq(1)
    expect(customer.default_card).not_to be_nil
    expect(customer.default_card).to eq customer.cards.data.first.id
    expect { customer.card }.to raise_error
    StripeMock.stop
  end

  it "creates a stripe customer without a card" do
    StripeMock.start
    customer = Stripe::Customer.create({
     email: 'cardless@example.com',
     description: "no card"
    })
    expect(customer.id).to match(/^test_cus/)
    expect(customer.email).to eq('cardless@example.com')
    expect(customer.description).to eq('no card')
    expect(customer.cards.count).to eq(0)
    expect(customer.cards.data.length).to eq(0)
    expect(customer.default_card).to be_nil
    StripeMock.stop
  end
    
  it "stores a created stripe customer in memory" do
    StripeMock.start
    customer = Stripe::Customer.create({
     email: 'storedinmemory@example.com',
     card: stripe_helper.generate_card_token,
    })
    customer2 = Stripe::Customer.create({
     email: 'bob@example.com',
     card: stripe_helper.generate_card_token,
    })
    customers = Stripe::Customer.all
    array = customers.to_a
    data = array.pop
    expect(customer.id).to match(/^test_cus/)
    expect(data.email).to eq('bob@example.com')
    data2 = array.pop
    expect(data2.id).not_to be_nil
    expect(data2.email).to eq('storedinmemory@example.com')
    StripeMock.stop
  end

  it "retrieves an identified stripe customer" do
    StripeMock.start
    original = Stripe::Customer.create({
     email: 'retrievsidentifiedcustomer@example.com',
     card: stripe_helper.generate_card_token,
    })
    customer = Stripe::Customer.retrieve(original.id)
    expect(customer.id).to eq(original.id)
    expect(customer.email).to eq(original.email)
    expect(customer.default_card).to eq(original.default_card)
    expect(customer.subscriptions.count).to eq(0)
    expect(customer.subscriptions.data).to be_empty
    StripeMock.stop
  end

  it "cannot retrieve a customer that doesn't exist" do
    StripeMock.start
    expect { Stripe::Customer.retrieve('nope') }.to raise_error {|e|
    expect(e).to be_a Stripe::InvalidRequestError
    expect(e.param).to eq('customer')
    expect(e.http_status).to eq(404)
    }
    StripeMock.stop
  end

  it "retrieves all customers" do
    StripeMock.start
    all = Stripe::Customer.all
    Stripe::Customer.create({ email: 'one@example.com' })
    Stripe::Customer.create({ email: 'two@example.com' })
    allnow = Stripe::Customer.all
    expect(allnow.count).to eq(all.count + 2)
    StripeMock.stop
  end

  it "updates a stripe customer" do
    StripeMock.start
    customer = Stripe::Customer.create(email: "updatecustomer@example.com")
    customer = Stripe::Customer.retrieve(customer.id)
    customer.email = "updatedcustomer@example.com"
    customer.save
    email = customer.email
    customer.description = 'new desc'
    customer.save
    expect(customer.email).to eq("updatedcustomer@example.com")
    expect(customer.description).to eq('new desc')
    StripeMock.stop
  end

  it "updates a stripe customer's card" do
    StripeMock.start
    customer = Stripe::Customer.create({
      id: 'test_customer_update', 
      card: stripe_helper.generate_card_token,
    })
    card = customer.cards.data.first
    expect(customer.default_card).to eq(card.id)
    expect(customer.cards.count).to eq(1)
    customer.card = stripe_helper.generate_card_token
    customer.save
    new_card = customer.cards.data.first
    expect(customer.cards.count).to eq(1)
    expect(customer.default_card).to eq(new_card.id)
    expect(new_card.id).not_to eq(card.id)
    StripeMock.stop
  end

  it "deletes a customer" do
    StripeMock.start
    customer = Stripe::Customer.create({
      email: 'deleteme@example.com',
      card: stripe_helper.generate_card_token,
    })
    customer = Stripe::Customer.retrieve(customer.id)
    customer = customer.delete
    expect(customer.deleted).to eq(true)
    StripeMock.stop
  end
end