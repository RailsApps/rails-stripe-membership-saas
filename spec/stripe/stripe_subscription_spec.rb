require 'stripe_mock'

include Warden::Test::Helpers
Warden.test_mode!

describe 'Subscription API' do

  let(:stripe_helper) { StripeMock.create_test_helper }

  before(:each) do
    StripeMock.start
  end

  after(:each) do
    StripeMock.stop
    Warden.test_reset!
  end

  it "allows customer to cancel subscription" do
    card_token = StripeMock.generate_card_token(card_number: "4242424242424242", exp_month: 12, exp_year: 2017)
    customer = Stripe::Customer.create(
      email: 'cancel@example.com',
      source: card_token,
      description: "a customer cancellation",
    )
    @user = FactoryGirl.create(:user, email: 'cancelsub@example.com')
    customer = Stripe::Customer.retrieve(customer.id)
    @user.email = customer.email
    expect(@user.email).to eq customer.email
    # creating plan
    plan = stripe_helper.create_plan(id: 'my_plan', amount: 1500)
    expect(plan.id).to eq('my_plan')
    expect(plan.amount).to eq(1500)
    charge = Stripe::Charge.create({
      amount: 1500,
      currency: 'usd',
      interval: 'month',
      plan: 'silver',
      customer: customer.id,
      description: 'a charge with a specific card',
      }, {
        idempotency_key: "95ea4310438306ch"
    })
    card_token = customer.sources.data[0].id
    charge = Stripe::Charge.retrieve(charge.id)
    customer = Stripe::Customer.retrieve(customer.id)
    customer.subscriptions.create({plan: plan.id})
    expect(card_token).to match /^test_cc/
    expect(charge.id).to match /^test_ch/
    expect(customer.id).to match /^test_cus/
    expect(customer.sources.data[0].id).to match /^test_cc/
    expect(customer.sources.data.length).to eq 1
    expect(customer.sources.data[0].id).not_to be_nil
    expect(customer.sources.data[0].last4).to eq '4242'
    customer.subscriptions.create(plan: 'my_plan')
    customer.save
    expect(customer.subscriptions[:url]).to match /\/v1\/customers\/test_cus\_.+\/subscriptions/
    customer = Stripe::Customer.retrieve(customer.id)
    expect(customer.subscriptions.data[0].id).to match /^test_su/
    expect(customer.subscriptions.data[0].status).to eq 'active'
    subscription = customer.subscriptions.data[0]
    subscription.delete
    customer = Stripe::Customer.retrieve(customer.id)
    customer.subscriptions.data[0].delete
    expect(customer.subscriptions.data[0].status).to eq 'canceled'
  end

  it 'allows customer to delete their account' do
    card_token = stripe_helper.generate_card_token(last4: "4242", exp_month: 12, exp_year: 2017)
    customer = Stripe::Customer.create(
      email: 'cancelcus@example.com',
      source: card_token,
      description: "a customer cancellation",
    )
    @user = FactoryGirl.create(:user, email: 'cancelcus@example.com')
    customer = Stripe::Customer.retrieve(customer.id)
    customer = Stripe::Customer.retrieve(customer.id)
    @user.email = customer.email
    expect(@user.email).to eq customer.email
    # creating plan
    plan = stripe_helper.create_plan(id: 'my_plan', amount: 1500)
    expect(plan.id).to eq('my_plan')
    expect(plan.amount).to eq(1500)
    charge = Stripe::Charge.create({
      amount: 1500,
      currency: 'usd',
      interval: 'month',
      customer: customer.id,
      description: 'a charge with a specific card',
      }, {
        idempotency_key: "95ea4310438306ch"
    })
    card_token = customer.sources.data[0].id
    charge = Stripe::Charge.retrieve(charge.id)
    customer = Stripe::Customer.retrieve(customer.id)
    expect(card_token).to match /^test_cc/
    expect(charge.id).to match /^test_ch/
    expect(customer.id).to match /^test_cus/
    expect(customer.sources.data[0].id).to match /^test_cc/
    expect(customer.sources.data.length).to eq 1
    expect(customer.sources.data[0].id).not_to be_nil
    expect(customer.sources.data[0].last4).to eq '4242'
    customer.delete
    expect(customer.id).to match /^test_cus/
    expect(customer.deleted).to be true
  end

  it "allows customer with two subscriptions to cancel one" do
    card_token = StripeMock.generate_card_token(card_number: '4242424242424242', exp_month: 12, exp_year: 2017)
    customer = Stripe::Customer.create(
      email: 'cancel@example.com',
      source: card_token,
      description: "a customer cancellation",
    )
    @user = FactoryGirl.create(:user, email: 'cancelone@example.com')
    customer = Stripe::Customer.retrieve(customer.id)
    @user.email = customer.email
    expect(@user.email).to eq customer.email
    card_token = stripe_helper.generate_card_token(card_number: '4242424242424242', exp_month: 11, exp_year: 2020)
    customer = Stripe::Customer.retrieve(customer.id)
    @user.email = customer.email
    expect(@user.email).to eq customer.email
    plan = stripe_helper.create_plan(id: 'my_plan', amount: 1500)

    expect(plan.id).to eq('my_plan')
    expect(plan.amount).to eq(1500)
    charge = Stripe::Charge.create({
      amount: 1500,
      currency: 'usd',
      interval: 'month',
      customer: customer.id,
      description: 'a charge with a specific card',
      }, {
        idempotency_key: "95ea4310438306ch"
    })
    card_token = customer.sources.data[0].id
    charge = Stripe::Charge.retrieve(charge.id)
    customer = Stripe::Customer.retrieve(customer.id)
    expect(card_token).to match /^test_cc/
    expect(charge.id).to match /^test_ch/
    expect(customer.id).to match /^test_cus/
    expect(customer.sources.data[0].id).to match /^test_cc/
    expect(customer.sources.data.length).to eq 1
    expect(customer.sources.data[0].id).not_to be_nil
    expect(customer.sources.data[0].last4).to eq '4242'
    customer.delete
    expect(customer.id).to match /^test_cus/
    expect(customer.deleted).to be true
    card_token = stripe_helper.generate_card_token(last4: "4242", exp_month: 12, exp_year: 2017)
    customer = Stripe::Customer.create(
      email: 'cancelcus@example.com',
      source: card_token,
      description: "a customer cancellation",
    )
    @user = FactoryGirl.create(:user, email: 'cancelcus@example.com')
    customer = Stripe::Customer.retrieve(customer.id)
    @user.email = customer.email
    expect(@user.email).to eq customer.email
    # creating plan
    plan = stripe_helper.create_plan(id: 'my_new_plan', amount: 2500)
    expect(plan.id).to eq('my_new_plan')
    expect(plan.amount).to eq(2500)
    charge = Stripe::Charge.create({
      amount: 2500,
      currency: 'usd',
      interval: 'month',
      customer: customer.id,
      description: 'a charge with a specific card',
      }, {
        idempotency_key: "95ea4310438306ch"
    })
    card_token = customer.sources.data[0].id
    charge = Stripe::Charge.retrieve(charge.id)
    customer = Stripe::Customer.retrieve(customer.id)
    expect(card_token).to match /^test_cc/
    expect(charge.id).to match /^test_ch/
    expect(customer.id).to match /^test_cus/
    expect(customer.sources.data[0].id).to match /^test_cc/
    expect(customer.sources.data.length).to eq 1
    expect(customer.sources.data[0].id).not_to be_nil
    expect(customer.sources.data[0].last4).to eq '4242'
    customer.delete
    expect(customer.id).to match /^test_cus/
    expect(customer.deleted).to be true
  end
end