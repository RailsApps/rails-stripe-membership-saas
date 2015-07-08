require 'pry'
require 'stripe_mock'

include Warden::Test::Helpers
Warden.test_mode!

RSpec.configure do

  def create_charge(card_token, uuid)
    Stripe::Charge.create(
      { amount: 1000, currency: 'usd', source: card_token, description: 'blah blah' }, 
      { idempotency_key: uuid },
    )
  end
end

describe 'Stripe idempotency_key' do
    
  let(:stripe_helper) { StripeMock.create_test_helper }

  before(:each) do
    StripeMock.start
  end

  after(:each) do
    StripeMock.stop
    Warden.test_reset!
  end

  it 'creates a customer' do
    customer = Stripe::Customer.create({
      email: 'johnny@appleseed.com',
      source: stripe_helper.generate_card_token(card_number: "4242424242424242", exp_year: 2022, exp_month: 2, cvc: '123'),
      description: "a customer description"
    }, {
        idempotency_key: "95ea4310438306cus" # just changed from ch ending to cus ending to differentiate from charge key
    })
    expect(customer.id).to match /^test_cus/
    charge = Stripe::Charge.create({
      amount: 1500,
      currency: 'usd',
      customer: customer.id,
      description: 'a charge with a specific card',
      }, {
        idempotency_key: "95ea4310438306ch"
    })
    expect(charge.id).to match /^test_ch/
  end

  it 'makes an idempotent charge' do
    uuid = 'abc123'
    source_token = stripe_helper.generate_card_token(card_number: "4242424242424242", exp_year: 2022, exp_month: 2, cvc: '123')
    expect(source_token).to match /^test_tok/
    charge = create_charge(source_token, uuid)
    # here, we completely ignore stripe's response, acting as if their response was interrupted by net failure
    # do nothing because we cannot see the response, so we do the charge again again, and we expect no error because we use the idempotent key
    # because we did make the charge, the stripe response has been sent to us. here, we simply ignore that fact, and
    # try to make the same charge again : we are faking ourselves out on this first if statement, as we know it is true
binding.pry  # update, the thing to do is first ask stripe for the charge, using the Stripe::Charge.retrieve(source_token) method.
    if (expect(charge.id).to match /^test_ch/) == true
      charge = create_charge(source_token, uuid)
    elsif (expect(charge.id).to match /^test_ch/) == true
      expect { create_charge(source_token, uuid) }.to_not raise_error
      expect(charge.id).to match /^test_ch/      
    end
  end

    ## so far, we have proven we can do a repeat of a charge with the same idempotency_key, 
    ## and receive a successful response
    ## now we change the idempotency_key, on the second try

  it 'prevents an idempotency_key changed charge' do
    uuid = 'abcde12345'
    source_token = stripe_helper.generate_card_token(card_number: "4242424242424242", exp_year: 2020, exp_month: 2, cvc: '123')
    expect(source_token).to match /^test_tok/
   #charge = create_charge(source_token, uuid)
    ## we have a successful charge, and we ignore it 'because of network error.'
    ## we want to test if a changed idempotency_key will succeed, or fail as it should
    ## we presume this first charge is successful, yet we do not get the response
    expect{create_charge(source_token, uuid)}.to_not raise_error { |e|
      expect(e).to be_a Stripe::InvalidRequestError
      expect(e.param).to eq('tok')
      expect(e.http_status).to eq(404)
    }
    ## so we try again, this time with a different uuid to see what happens
    expect{create_charge(source_token, uuid + '4')}.to raise_error { |e|
      expect(e).to be_a Stripe::InvalidRequestError
      expect(e.param).to eq('tok')
      expect(e.http_status).to eq(404)
    }
  end
end