module StripeHelpers

  require 'rails_helper'
  require 'stripe_mock'
  require 'thin'

  StripeMock.spawn_server

  describe 'StripeToken' do

    let(:stripe_helper) { StripeMock.create_test_helper }

    before(:each) do
      StripeMock.start
    end

    after(:each) do
      StripeMock.stop
    end
    
   describe 'create stripe token' do
      it "creates a stripe token" do
        stripeToken = stripe_helper.generate_card_token
        Rails.logger.info "Your stripeToken has been generated as #{stripeToken} and is to be used once. "
        expect(stripeToken).to match(/test_tok/)
      end
    end

   describe 'Card Error Prep' do
      it "prepares a card error" do
        StripeMock.prepare_card_error(:card_declined, :new_charge)
        cus = Stripe::Customer.create email: 'alice@example.com',
        :card => stripe_helper.generate_card_token({ number:'4242424242424242', brand: 'Visa' })
        expect { charge = Stripe::Charge.create({
          amount: 900,
          currency: 'usd',
          customer: cus,
          card: cus.sources.first,
          description: 'hello'
        })
      }.to raise_error Stripe::CardError
      end
    end

    describe 'card declined error' do
      it "mocks a declined card error" do
        # Prepares an error for the next create charge request
        StripeMock.prepare_card_error(:card_declined, :new_charge)
        expect { Stripe::Charge.create }.to raise_error {|e|
          expect(e).to be_a Stripe::CardError
          expect(e.http_status).to eq(402)
          expect(e.code).to eq('card_declined')
        }
      end
    end
  end
end