require 'stripe_mock'

describe 'Card Error Prep' do
  let(:stripe_helper) { StripeMock.create_test_helper }

  it 'prepares a card error' do
    StripeMock.start
    StripeMock.prepare_card_error(:card_declined, :new_charge)
    cus = Stripe::Customer.create(email: 'alice@example.com')
    expect { Stripe::Charge.create({
      amount: 900,
      currency: 'usd',
      source: stripe_helper.generate_card_token(number: '4242424242424241', brand: 'Visa'),
      description: 'hello'
      })
    }.to raise_error(Stripe::CardError, 'The card was declined')
    StripeMock.stop
  end
end
