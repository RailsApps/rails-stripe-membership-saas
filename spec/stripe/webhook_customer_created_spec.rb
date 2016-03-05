require 'stripe_mock'
include Warden::Test::Helpers
Warden.test_mode!

describe 'Stripe Customer Webhooks' do
  let(:stripe_helper) { StripeMock.create_test_helper }

  before(:each) do
    StripeMock.start
  end

  after(:each) do
    StripeMock.stop
    Warden.test_reset!
  end

  it 'mocks a stripe webhook', live: true do
    # source reference for mock_webhook_event method:
    # https://github.com/rebelidealist/stripe-ruby-mock/blob/master/lib/stripe_mock/api/webhooks.rb
    event = StripeMock.mock_webhook_event('customer.created')
    expect(event.object).to eq 'event'
    expect(event.data.object).to be_a Stripe::Customer
    expect(event.data.object.object).to eq 'customer'
    expect(event.data.object.id).to match(/^cus_/)

    # a customer.created event will have the same information as
    #  retrieving the relevant customer would have
    # https://stripe.com/docs/api#retrieve_event
    verified_event = Stripe::Event.retrieve(event.id)

    customer_object = verified_event.data.object
    expect(customer_object.id).to match(/^cus_/)
    expect(customer_object.default_card).to_not be_nil
    expect(customer_object.default_card).to match(/^cc_/)
    expect(verified_event.id).to match(/^test_evt_/)
    expect(verified_event.type).to eq 'customer.created'

    customer = Stripe::Customer.create(email: 'customer@example.com')
    customer_id = customer.id
    expect(customer.subscriptions.total_count).to eq 0

    customer = Stripe::Customer.retrieve(customer_id)
    expect(customer.sources.object).to eq 'list'
    expect(customer.default_source).to eq nil
    expect(customer.sources.url).to match(/^\/v1\/customers\/test_cus\_.+\/sources/)
    # card below is created in StripeMock.mock_webhook_event above
    # see https://github.com/rebelidealist/stripe-ruby-mock/blob/master/lib/stripe_mock/api/webhooks.rb
    expect(verified_event.data.object.default_card).to match(/^cc\_/)
    expect(verified_event.data.object).to be_truthy
    expect(verified_event.id).to match(/^test_evt/)
    expect(verified_event.data.object.id).to match(/^cus\_00000000000000/)
    expect(verified_event.data.object[:id]).to match(/^cus\_00000000000000/)
    expect(verified_event.data.object.object).to eq 'customer'
    expect(verified_event.data.object.livemode).to be false
    expect(verified_event.data.object.description).to be nil
    expect(verified_event.data.object.email).to eq 'bond@mailinator.com'
    expect(verified_event.data.object.delinquent).to be true
    expect(verified_event.data.object.sources.data).to be_truthy
    expect(verified_event.data.object.sources.data.count).to eq 1
    # Note these next two are same test called in different manner.
    expect(verified_event.data.object.sources.data[0][:id]).to match(/^cc\_/)
    expect(verified_event.data.object.sources.data.first[:id]).to match(/^cc\_/)
    # We will stay with .first as we have only one card created.
    expect(verified_event.data.object.sources.data.first[:customer]).to match(/^cus\_/)
    expect(verified_event.data.object.sources.data.first[:last4]).to eq '0341'
    expect(verified_event.data.object.sources.data.first[:type]).to eq 'Visa'
    expect(verified_event.data.object.sources.data.first[:funding]).to eq 'credit'
    expect(verified_event.data.object.sources.data.first.exp_month).to eq 12
    # Note this next line passes if you do not give your card creation a current exp_year.
    # The reason for this is the StipeMock.gen_card_tk method returns the year as 2013.
    expect(verified_event.data.object.sources.data.first.exp_year).to eq 2013
    # TODO: fix this so the exp_year from stripe-ruby-mock is 2019 aka valid card.
    # expect(verified_event.data.object.sources.data.first.exp_year).to eq 2019
    expect(verified_event.data.object.sources.data.first.fingerprint).to_not be nil
    expect(verified_event.data.object.sources.data.first.customer).to match(/^cus\_/)
    expect(verified_event.data.object.sources.data.first.country).to eq 'US'
    expect(verified_event.data.object.sources.data.first[:name]).to eq 'Johnny Goodman'
    expect(verified_event.data.object.sources.data.first.address_line1).to be nil
    expect(verified_event.data.object.sources.data.first.address_line2).to be nil
    expect(verified_event.data.object.sources.data.first.address_city).to be nil
    expect(verified_event.data.object.sources.data.first.address_state).to be nil
    expect(verified_event.data.object.sources.data.first.address_zip).to be nil
    expect(verified_event.data.object.sources.data.first.address_country).to be nil
    expect(verified_event.data.object.sources.data.first.cvc_check).to eq 'pass'
    expect(verified_event.data.object.sources.data.first.address_line1_check).to be nil
    # If address_line1 was provided, results of the check:
    # pass, fail, unavailable, or unchecked.
    expect(verified_event.data.object.sources.data.first.address_zip_check).to be nil
    expect(verified_event.data.object.object).to eq 'customer'
    expect(verified_event.data.object.livemode).to be false
    expect(verified_event.data.object.description).to be nil

    # TODO: run test where we enter email for the customer, not the event creation.
    # expect(verified_event.data.object.email).to eq 'event_webhook@example.com'
    # where do we add the customer email prior to or with the event creation ? 20151111
    # the above todo is because stripe-ruby-mock quietly provides this email address:
    expect(verified_event.data.object.email).to eq 'bond@mailinator.com'

    expect(verified_event.data.object.delinquent).to be true
    expect(verified_event.data.object.metadata).to be_a Stripe::StripeObject
    expect(verified_event.data.object.subscription).to be nil
    expect(verified_event.data.object.discount).to be nil
    expect(verified_event.data.object.discount).to be nil
    expect(verified_event.data.object.account_balance).to eq 0
    expect(verified_event.data.object.sources.object).to eq 'list'
    expect(verified_event.id).to match(/^test_evt\_/)
    expect(verified_event.created).to_not be nil
    expect(verified_event.livemode).to eq false
    expect(verified_event.type).to eq 'customer.created'
    expect(verified_event.object).to eq 'event'
    expect(verified_event.data.object.account_balance).to eq 0
    expect(verified_event.data.count).to eq 1
    expect(verified_event.url).to match(/\/v1\/events\/test_evt_/)
    expect(verified_event.data.object.sources .data).to_not be_nil
    expect(verified_event.data.object.sources.data.first[:id]).to match(/^cc\_/)
    expect(verified_event.data.object.sources.data.first[:last4]).to eq '0341'
    expect(verified_event.data.object.sources.data.first[:type]).to eq 'Visa'
    expect(verified_event.data.object.sources.data.first[:brand]).to eq 'Visa'
    expect(verified_event.data.object.sources.data.first[:funding]).to eq 'credit'
    expect(verified_event.data.object.sources.data.first[:exp_month]).to eq 12

    # out of date stripe_mock : still this day ? 20151111 ? TODO: verify
    expect(verified_event.data.object.sources.data.first[:exp_year]).to eq 2013
    # TODO: 20151115 : revisit this one another time
    # expect(verified_event.data.object.sources.data.first[:exp_year]).to eq 2019

    expect(verified_event.data.object.sources.data.first[:fingerprint]).to_not be nil
    expect(verified_event.data.object.sources.data.first[:customer]).to match(/^cus\_/)
    expect(verified_event.data.object.sources.data.first[:country]).to eq 'US'
    expect(verified_event.data.object.sources.data.first[:name]).to eq 'Johnny Goodman'
    expect(verified_event.data.object.sources.data.first[:address_line1]).to eq nil
    expect(verified_event.data.object.sources.data.first[:address_line2]).to eq nil
    expect(verified_event.data.object.sources.data.first[:address_city]).to eq nil
    expect(verified_event.data.object.sources.data.first[:address_state]).to eq nil
    expect(verified_event.data.object.sources.data.first[:address_zip]).to eq nil
    expect(verified_event.data.object.sources.data.first[:address_country]).to eq nil
    expect(verified_event.data.object.sources.data.first[:cvc_check]).to eq 'pass'
    expect(verified_event.data.object.sources.data.first[:address_line1_check]).to eq nil
    expect(verified_event.data.object.sources.data.first[:address_zip_check]).to eq nil
    customer_object = verified_event.data.object
    expect(customer_object.id).to_not be_nil
    expect(customer_object.default_card).to_not be_nil # ? out of date stripe_mock
    # expect(customer_object.default_source).to_not be_nil
    expect(customer_object.default_card).to match(/^cc\_/) # ? out of date stripe_mock
    # expect(customer_object.default_source).to match /^cc\_/
  end
end
