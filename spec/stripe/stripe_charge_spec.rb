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
    charge = Stripe::Charge.create(
      amount: 995,
      currency: 'USD',
      card: stripe_helper.generate_card_token(last4: "4242", exp_month: 12, exp_year: 2018),
      description: 'card charge'
    )
    expect(charge.id).to match(/^test_ch/)
    expect(charge.amount).to eq(995)
    expect(charge.description).to eq('card charge')
    expect(charge.captured).to eq(true)
    StripeMock.stop
  end

  it "creates a stripe charge item with a customer and card id" do
    StripeMock.start
    customer = Stripe::Customer.create({
      email: 'chargeitem@example.com',
      card: stripe_helper.generate_card_token(number: '4242424242424242'),
      description: "customer creation with card token"
    })
    card_token = customer.cards.data[0].id
    expect(customer.cards.data.length).to eq(1)
    expect(customer.cards.data[0].id).not_to be_nil
    expect(customer.cards.data[0].last4).to eq('4242')
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
    card = customer.cards.data[0]
    charge = Stripe::Charge.create({
      amount: 995,
      currency: 'USD',
      customer: customer.id,
      card: stripe_helper.generate_card_token(number: '4242424242424242', amount: 995),
      description: 'a charge with a specific card',
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
    expect(charge.amount).to eq(995)
    expect(charge.description).to eq('a charge with a specific card')
    expect(charge.captured).to eq(true)
    expect(charge.card.last4).to eq('4242')
    expect(charge.id).to match(/^test_ch/)
    end
    StripeMock.stop
  end

  it "requires a valid card token", :live => true do  # passing
    StripeMock.start
    expect {
      charge = Stripe::Charge.create(
      amount: 995,
      currency: 'usd',
      card: 'bogus_card_token'
      )
    }.to raise_error(Stripe::InvalidRequestError, /Invalid token id/)
    StripeMock.stop
  end

  it "retrieves a stripe charge" do  # passing
    StripeMock.start
    original = Stripe::Charge.create({
      amount: 995,
      currency: 'USD',
      card: stripe_helper.generate_card_token
    })
    charge = Stripe::Charge.retrieve(original.id)
    expect(charge.id).to eq(original.id)
    expect(charge.amount).to eq(original.amount)
    StripeMock.stop
  end

  it "cannot retrieve a charge that doesn't exist" do  # passing
    StripeMock.start
    expect { Stripe::Charge.retrieve('nope') }.to raise_error {|e|
    expect(e).to be_a Stripe::InvalidRequestError
    expect(e.param).to eq('charge')
    expect(e.http_status).to eq(404)
   }
    StripeMock.stop
  end

end
