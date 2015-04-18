require 'stripe_mock'

include Warden::Test::Helpers
Warden.test_mode!

describe 'Charge API' do
    
  let(:stripe_helper) { StripeMock.create_test_helper }

  after(:each) do
    Warden.test_reset!
  end

  it "creates a stripe charge item with a card token" do
    StripeMock.start
   charge = Stripe::Charge.create({
      amount: 900,
      currency: "usd",
      source: stripe_helper.generate_card_token(last4: "1123", exp_month: 11, exp_year: 2099),
      description: "Charge for user@example.com",
      }, {
        idempotency_key: "95ea4310438306ch"
    })
    expect(charge.id).to match(/^test_ch/)
    expect(charge.amount).to eq(900)
    expect(charge.description).to eq('Charge for user@example.com')
    expect(charge.captured).to eq(true)
    StripeMock.stop
  end

  it "creates a stripe charge item with a customer and card id" do
    StripeMock.start
    card_token = stripe_helper.generate_card_token(last4: "1123", exp_month: 11, exp_year: 2099)
    customer = Stripe::Customer.create({
      email: 'user@example.com',
      card: card_token,
      description: "customer creation with card token"
    })
    charge = Stripe::Charge.create({
      amount: 900,
      currency: "usd",
      source: stripe_helper.generate_card_token(last4: "1123", exp_month: 11, exp_year: 2099),
      description: "Charge for user@example.com",
      }, {
        idempotency_key: "95ea4310438306ch"
    })
    charge = Stripe::Charge.retrieve(charge.id)
    expect(charge.id).to match(/^test_ch/)
    customer = Stripe::Customer.retrieve(customer.id)
    expect(customer.id).to match(/^test_cus/)
    expect(customer.card).to match(/^test_tok/)
    StripeMock.stop
  end

  it "creates a stripe charge with a specific customer card" do
    StripeMock.start
    begin
    customer = Stripe::Customer.create({
      email: 'chargeitem@example.com',
      card: stripe_helper.generate_card_token(number: '4242424242424242'),
      description: "customer creation with card token"
    })
    card = customer.sources.data[0]
    charge = Stripe::Charge.create({
      amount: 900,
      currency: "usd",
      source: stripe_helper.generate_card_token(last4: "1123", exp_month: 11, exp_year: 2099),
      description: "Charge for user@example.com",
      }, {
        idempotency_key: "95ea4310438306ch"
    })
    rescue Stripe::CardError => e
    body = e.json_body
    err = body[:error]
    puts "Status is: #{e.http_status}"
    puts "Type is: #{err[:type]}"
    puts "Code is: #{err[:code]}"
    # param is '' in this case
    puts "Param is: #{err[:param]}"
    puts "Message is: #{err[:message]}"
    rescue Stripe::InvalidRequestError => e
    # Invalid parameters were supplied to Stripe's API
    rescue Stripe::AuthenticationError => e
    # Authentication with Stripe's API failed
    # (maybe you changed API keys recently)
    rescue Stripe::APIConnectionError => e
    # Network communication with Stripe failed
    rescue Stripe::StripeError => e
    # Display a very generic error to the user, and maybe send
    # yourself an email
    rescue => e # Something else happened, completely unrelated to Stripe
    expect(charge.amount).to eq(900)
    expect(charge.description).to eq('a charge with a specific card')
    expect(charge.captured).to eq(true)
    expect(charge.card.last4).to eq('4242')
    expect(charge.id).to match(/^test_ch/)
    end
    StripeMock.stop
  end

  it "requires a valid card token", :live => true do
    StripeMock.start
    expect {
      charge = Stripe::Charge.create({
        amount: 900,
        currency: "usd",
        source: 'bogus_card_token',
        description: "Charge for user@example.com",
      }, {
        idempotency_key: "95ea4310438306ch"
      })
    }.to raise_error(Stripe::InvalidRequestError, /Invalid token id/)
    StripeMock.stop
  end

  it "retrieves a stripe charge" do
    StripeMock.start
      original = Stripe::Charge.create({
      amount: 900,
      currency: "usd",
      source: stripe_helper.generate_card_token(last4: "1123", exp_month: 11, exp_year: 2099),
      description: "Charge for user@example.com",
      }, {
       idempotency_key: "95ea4310438306ch"
    })
    charge = Stripe::Charge.retrieve(original.id)
    expect(charge.id).to eq(original.id)
    expect(charge.amount).to eq(original.amount)
    StripeMock.stop
  end

  it "cannot retrieve a charge that doesn't exist" do
    StripeMock.start
    expect { Stripe::Charge.retrieve('nope') }.to raise_error {|e|
    expect(e).to be_a Stripe::InvalidRequestError
    expect(e.param).to eq('charge')
    expect(e.http_status).to eq(404)
   }
    StripeMock.stop
  end

end
