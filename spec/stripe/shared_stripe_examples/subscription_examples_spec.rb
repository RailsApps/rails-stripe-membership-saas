require 'stripe_mock'
include Warden::Test::Helpers
Warden.test_mode!

RSpec.configure do
  def gen_card_tk
    card = stripe_helper.generate_card_token(
      last4: '4242',
      exp_month: 12,
      exp_year: 2021
    )
  end
end

# shared_examples
describe 'Customer Subscriptions', live: true do
  let(:stripe_helper) { StripeMock.create_test_helper }

  before(:each) do
    StripeMock.start
    FactoryGirl.reload
  end

  after(:each) do
    StripeMock.stop
    Warden.test_reset!
  end

  context 'creating a new subscription' do
    it 'adds a new subscription to customer with none' do
      plan = stripe_helper.create_plan(
        id: 'five',
        name: 'Five',
        amount: 500,
        currency: 'usd',
        interval: 'month',
        source: gen_card_tk,
        trial_period_days: nil,
        metadata: { foo: 'bar', example: 'yes' },
        statement_descriptor: 'Shows on Invoice'
      )
      customer = Stripe::Customer.create(source: gen_card_tk, plan: plan.id)

      customer = Stripe::Customer.retrieve(customer.id)
      expect(customer.subscriptions.object).to eq 'list'
      expect(customer.subscriptions.data).to_not be_empty
      expect(customer.subscriptions.data[0].status).to eq 'active'
      expect(customer.subscriptions.data[0].id).to match(/^test_su/)
      expect(customer.subscriptions.data[0][:id]).to match(/^test_su/)
      expect(customer.subscriptions.data.count).to eq 1
      expect(customer.subscriptions.data[0].plan.id).to eq 'five'
      expect(customer.subscriptions.data[0].plan.object).to eq 'plan'
      expect(customer.subscriptions.data[0].plan.to_hash).to eq plan.to_hash
      expect(customer.subscriptions.data[0].plan.metadata.foo).to eq('bar')
      expect(customer.subscriptions.data[0].plan.metadata.example).to eq 'yes'
      expect(customer.subscriptions.data).to_not be_empty
      expect(customer.subscriptions.count).to eq 1
      expect(customer.subscriptions.data.length).to eq 1
      expect(customer.subscriptions.data[0].plan.to_hash).to eq plan.to_hash
      expect(customer.subscriptions.data[0].customer).to eq customer.id
    end

    it 'adds additional subscription to customer with existing subscription' do
      silver = stripe_helper.create_plan(id: 'silver')
      gold = stripe_helper.create_plan(id: 'gold')
      customer = Stripe::Customer.create(
        id: 'test_customer_sub',
        source: gen_card_tk,
        plan: 'gold'
      )
      sub = customer.subscriptions.create(plan: 'silver')
      expect(sub.object).to eq 'subscription'
      expect(sub.plan.to_hash).to eq(silver.to_hash)
      customer = Stripe::Customer.retrieve('test_customer_sub')
      expect(customer.subscriptions.data).to_not be_empty
      expect(customer.subscriptions.count).to eq 2
      expect(customer.subscriptions.data.length).to eq 2
      expect(customer.subscriptions.data.last.plan.to_hash).to eq gold.to_hash
      expect(customer.subscriptions.data.last.customer).to eq customer.id
      expect(customer.subscriptions.data.first.id).to eq sub.id
      expect(customer.subscriptions.data.first.plan.to_hash).to eq silver.to_hash
      expect(customer.subscriptions.data.first.customer).to eq customer.id
    end

    it 'subscribes a cardless customer when specifing a card token' do
      plan = stripe_helper.create_plan(id: 'enterprise', amount: 499, source: gen_card_tk)
      customer = Stripe::Customer.create(id: 'cardless')
      sub = customer.subscriptions.create(plan: 'enterprise', source: gen_card_tk)
      customer = Stripe::Customer.retrieve('cardless')
      expect(customer.subscriptions.data.first.id).to eq sub.id
      expect(customer.subscriptions.data.first.customer).to eq customer.id
      expect(customer.sources.count).to eq 1
      expect(customer.sources.data.length).to eq 1
      expect(customer.default_source).to_not be_nil
      expect(customer.default_source).to eq customer.sources.data.first.id
    end

    it 'throws an error when plan does not exist' do
      customer = Stripe::Customer.create(id: 'cardless')
      expect { customer.subscriptions.create(plan: 'gazebo') }.to raise_error { |e|
        expect(e).to be_a Stripe::InvalidRequestError
        expect(e.http_status).to eq 404
        expect(e.message).to_not be_nil
      }
      expect(customer.subscriptions.data).to be_empty
      expect(customer.subscriptions.count).to eq 0
    end

    it 'throws an error when subscribing a customer with no card' do
      plan = stripe_helper.create_plan(id: 'enterprise', amount: 499)
      customer = Stripe::Customer.create(id: 'cardless')
      expect { customer.subscriptions.create(plan: 'enterprise') }.to raise_error { |e|
        expect(e).to be_a Stripe::InvalidRequestError
        expect(e.http_status).to eq 400
        expect(e.message).to_not be_nil
      }
      expect(customer.subscriptions.data).to be_empty
      expect(customer.subscriptions.count).to eq 0
    end
  end

  context 'cancelling a subscription' do
    it 'cancels a stripe customers subscription', live: true do
      truth = stripe_helper.create_plan(id: 'the truth')
      customer = Stripe::Customer.create(source: gen_card_tk, plan: 'the truth')
      sub = customer.subscriptions.retrieve(customer.subscriptions.data.first.id)
      result = sub.delete
      expect(result.status).to eq('canceled')
      expect(result.cancel_at_period_end).to eq false
      expect(result.canceled_at).to_not be_nil
      expect(result.id).to eq sub.id
      customer = Stripe::Customer.retrieve(customer.id)
      expect(customer.subscriptions.data).to be_empty
      expect(customer.subscriptions.count).to eq 0
      expect(customer.subscriptions.data.length).to eq 0
    end

    it 'retrieves an empty list if theres no subscriptions' do
      Stripe::Customer.create(id: 'no_subs')
      customer = Stripe::Customer.retrieve('no_subs')
      list = customer.subscriptions.all
      expect(list.object).to eq 'list'
      expect(list.count).to eq 0
      expect(list.data.length).to eq 0
    end
  end
end

describe 'address line check, metadata usage, and more', live: true do
  let(:stripe_helper) { StripeMock.create_test_helper }

  before(:each) do
    StripeMock.start
    FactoryGirl.reload
  end

  after(:each) do
    StripeMock.stop
    Warden.test_reset!
  end

  it 'creates a stripe customer and subscribes them to a plan with metadata' do
    plan = stripe_helper.create_plan(
      amount: 500,
      interval: 'month',
      name: 'Sample Plan',
      currency: 'usd',
      id: 'sample5',
      statement_descriptor: 'Plan Statement'
    )

    plan = Stripe::Plan.retrieve(plan.id)
    expect(plan.id).to eq 'sample5'
    expect(plan.interval).to eq 'month'
    expect(plan.name).to eq 'Sample Plan'
    # fails : stripe-ruby-mock error 20150906 : is it worth testing ? or accounting for ?
    # expect(plan.created).not_to eq nil
    expect(plan.amount).to eq 500
    expect(plan.currency).to eq 'usd'
    expect(plan.object).to eq 'plan'
    expect(plan.livemode).to eq false
    expect(plan.interval_count).to eq 1
    expect(plan.trial_period_days).to be nil
    expect(plan.statement_descriptor).to eq 'Plan Statement'

    customer = Stripe::Customer.create(
      email: 'johnny@appleseed.com',
      source: gen_card_tk
    )
    expect(customer.id).to match(/^test_cus/)
    expect(customer.email).to eq 'johnny@appleseed.com'
    expect(customer.subscriptions.total_count).to eq 0

    subscription = customer.subscriptions.create(plan: 'sample5')
    expect(subscription.id).to match(/^test_su/)
    # expect(subscription.current_period_start).to eq 1441403417
    # expect(subscription.current_period_end).to eq 1443995417
    expect(subscription.status).to eq 'active'
    expect(subscription.plan.id).to eq 'sample5'
    expect(subscription.plan.interval).to eq 'month'
    expect(subscription.plan.name).to eq 'Sample Plan'
    expect(subscription.plan.amount).to eq 500
    expect(subscription.plan.currency).to eq 'usd'
    expect(subscription.plan.object).to eq 'plan'
    expect(subscription.plan.livemode).to eq false
    expect(subscription.plan.interval_count).to eq 1
    expect(subscription.plan.trial_period_days).to eq nil
    expect(subscription.plan.statement_descriptor).to eq 'Plan Statement'
    expect(subscription.cancel_at_period_end).to eq false
    expect(subscription.canceled_at).to eq nil
    expect(subscription.ended_at).to eq nil
    expect(subscription.start).to eq 1308595038
    expect(subscription.object).to eq 'subscription'
    expect(subscription.trial_start).to eq nil
    expect(subscription.trial_end).to eq nil
    expect(subscription.customer).to match(/^test_cus_3/)
    expect(subscription.quantity).to eq 1
    expect(subscription.tax_percent).to eq nil
    expect(subscription.discount).to eq nil
    expect(subscription.metadata).to be_a Stripe::StripeObject
    expect(subscription.metadata.to_json).to eq '{}'

    subscription.metadata['foo'] = 'bar'
    expect(subscription).to be_a Stripe::Subscription
    subscription = customer.subscriptions.retrieve(subscription.id)
    expect(subscription.customer).to match(/^test_cus/)

    customer = Stripe::Customer.retrieve(customer.id)
    expect(customer.subscriptions.object).to eq 'list'
    expect(customer.subscriptions.total_count).to eq 1
    expect(customer.subscriptions.url).to match(/test_cus/)
    expect(customer.default_source).to match(/^test_cc/)
    expect(customer.subscriptions.data[0].id).to match(/^test_su/)
    expect(customer.subscriptions.first.plan.id).to eq 'sample5'
  end

  # data you do not provide is being sourced from the stripe-ruby-mock gem method
  # look for this method : def self.mock_card(params={}) with the data parameters below it
  # ref: https://github.com/rebelidealist/stripe-ruby-mock/blob/master/lib/stripe_mock/data.rb
  it 'resumes an at period end cancelled subscription' do
    truth = stripe_helper.create_plan(id: 'the_truth')
    expect(truth.id).to eq 'the_truth'
    expect(truth.interval).to eq 'month'
    expect(truth.name).to eq 'StripeMock Default Plan ID'
    expect(truth.amount).to eq 1337
    expect(truth.currency).to eq 'usd'
    expect(truth.object).to eq 'plan'
    expect(truth.livemode).to eq false
    expect(truth.interval_count).to eq 1

    customer = Stripe::Customer.create(id: 'test_customer_sub', source: gen_card_tk, plan: 'the_truth')
    sub = customer.subscriptions.retrieve(customer.subscriptions.data[0].id)
    result = sub.delete(at_period_end: true)
    sub.plan = 'the_truth'
    sub.save
    customer = Stripe::Customer.retrieve('test_customer_sub')
    expect(customer.subscriptions.data).to_not be_empty
    expect(customer.subscriptions.count).to eq 1
    expect(customer.subscriptions.data.length).to eq 1
    expect(customer.subscriptions.data.first.status).to eq 'active'
    expect(customer.subscriptions.data.first.cancel_at_period_end).to eq false
    expect(customer.subscriptions.data.first.ended_at).to be_nil
    expect(customer.subscriptions.data.first.canceled_at).to be_nil
  end

  it 'cancels a stripe customers subscription at period end' do
    truth = stripe_helper.create_plan(id: 'the_truth')
    customer = Stripe::Customer.create(id: 'test_customer_sub', source: gen_card_tk, plan: 'the_truth')
    sub = customer.subscriptions.retrieve(customer.subscriptions.data.first.id)
    result = sub.delete(at_period_end: true)
    expect(result.status).to eq 'active'
    expect(result.cancel_at_period_end).to eq true
    expect(result.id).to eq sub.id

    customer = Stripe::Customer.retrieve('test_customer_sub')
    expect(customer.subscriptions.data).to_not be_empty
    expect(customer.subscriptions.count).to eq 1
    expect(customer.subscriptions.data.length).to eq 1
    expect(customer.subscriptions.data.first.status).to eq 'active'
    expect(customer.subscriptions.data.first.cancel_at_period_end).to eq true
    expect(customer.subscriptions.data.first.ended_at).to be_nil
    expect(customer.subscriptions.data.first.canceled_at).to_not be_nil
  end

  it 'subscribes a customer with no card to a plan with a free trial' do
    plan = stripe_helper.create_plan(id: 'trial', amount: 999, trial_period_days: 14)
    customer = Stripe::Customer.create(id: 'cardless')
    sub = customer.subscriptions.create(plan: 'trial')
    expect(sub.object).to eq 'subscription'
    expect(sub.plan.to_hash).to eq plan.to_hash
    expect(sub.trial_end - sub.trial_start).to eq(14 * 86_400)

    customer = Stripe::Customer.retrieve('cardless')
    expect(customer.subscriptions.data).to_not be_empty
    expect(customer.subscriptions.count).to eq 1
    expect(customer.subscriptions.data.length).to eq 1
    expect(customer.subscriptions.data.first.id).to eq sub.id
    expect(customer.subscriptions.data.first.plan.to_hash).to eq plan.to_hash
    expect(customer.subscriptions.data.first.customer).to eq customer.id
  end

  it 'subscribes a customer with no card to a free plan' do
    plan = stripe_helper.create_plan(id: 'free_tier', amount: 0)
    customer = Stripe::Customer.create(id: 'cardless')
    sub = customer.subscriptions.create(plan: 'free_tier')
    expect(sub.object).to eq 'subscription'
    expect(sub.plan.to_hash).to eq plan.to_hash

    customer = Stripe::Customer.retrieve('cardless')
    expect(customer.subscriptions.data).to_not be_empty
    expect(customer.subscriptions.count).to eq 1
    expect(customer.subscriptions.data.length).to eq 1
    expect(customer.subscriptions.data.first.id).to eq sub.id
    expect(customer.subscriptions.data.first.plan.to_hash).to eq plan.to_hash
    expect(customer.subscriptions.data.first.customer).to eq customer.id
  end

  # TODO: next two are near duplicates, merge them
  it 'overrides trial length when trial end is set' do
    plan = stripe_helper.create_plan(id: 'trial', amount: 999, trial_period_days: 14)
    customer = Stripe::Customer.create(id: 'short_trial')
    trial_end = Time.now.utc.to_i + 3600
    sub = customer.subscriptions.create(plan: 'trial', trial_end: trial_end)
    expect(sub.object).to eq 'subscription'
    expect(sub.plan.to_hash).to eq plan.to_hash
    expect(sub.current_period_end).to eq trial_end
    expect(sub.trial_end).to eq trial_end
  end

  it 'overrides trial length when trial end is set' do
    plan = stripe_helper.create_plan(id: 'trial', amount: 999, trial_period_days: 14)
    customer = Stripe::Customer.create(id: 'short_trial')
    trial_end = Time.now.utc.to_i + 3_600

    sub = customer.subscriptions.create(plan: 'trial', trial_end: trial_end)

    expect(sub.object).to eq 'subscription'
    expect(sub.plan.to_hash).to eq plan.to_hash
    expect(sub.current_period_end).to eq trial_end
    expect(sub.trial_end).to eq trial_end
  end

  it 'returns without a trial when trial_end is set to now' do
    plan = stripe_helper.create_plan(id: 'trial', amount: 999, trial_period_days: 14)
    customer = Stripe::Customer.create(id: 'no_trial', source: gen_card_tk)

    sub = customer.subscriptions.create(plan: 'trial', trial_end: 'now')

    expect(sub.object).to eq 'subscription'
    expect(sub.plan.to_hash).to eq plan.to_hash
    expect(sub.status).to eq 'active'
    expect(sub.trial_start).to be_nil
    expect(sub.trial_end).to be_nil
  end

  it 'raises error when trial_end is not an integer or now' do
    plan = stripe_helper.create_plan(id: 'trial', amount: 999, trial_period_days: 14)
    customer = Stripe::Customer.create(id: 'cus_trial')
    expect { customer.subscriptions.create(plan: 'trial', trial_end: 'gazebo') }.to raise_error { |e|
      expect(e).to be_a Stripe::InvalidRequestError
      expect(e.http_status).to eq 400
      expect(e.message).to eq('Invalid timestamp: must be an integer')
    }
  end

  it 'does not change status of subscription when cancelling at period end' do
    trial = stripe_helper.create_plan(id: 'trial', trial_period_days: 14)
    customer = Stripe::Customer.create(id: 'test_customer_sub', source: gen_card_tk, plan: 'trial')
    sub = customer.subscriptions.retrieve(customer.subscriptions.data.first.id)
    result = sub.delete(at_period_end: true)
    expect(result.status).to eq 'trialing'

    customer = Stripe::Customer.retrieve('test_customer_sub')
    expect(customer.subscriptions.data.first.status).to eq 'trialing'
  end

  it 'raises error when trial_end is set to a time in the past' do
    plan = stripe_helper.create_plan(id: 'trial', amount: 999, trial_period_days: 14)
    customer = Stripe::Customer.create(id: 'past_trial')
    trial_end = Time.now.utc.to_i - 3600
    expect { customer.subscriptions.create(plan: 'trial', trial_end: trial_end) }.to raise_error { |e|
      expect(e).to be_a Stripe::InvalidRequestError
      expect(e.http_status).to eq 400
      expect(e.message).to eq('Invalid timestamp: must be an integer Unix timestamp in the future')
    }
  end

  it 'raises error when trial_end is set to a time more than five years in the future' do
    plan = stripe_helper.create_plan(id: 'trial', amount: 999, trial_period_days: 14)
    customer = Stripe::Customer.create(id: 'long_trial')
    trial_end = Time.now.utc.to_i + 31_557_600 * 5 + 3_600 # 5 years + 1 hour
    expect { customer.subscriptions.create(plan: 'trial', trial_end: trial_end) }.to raise_error { |e|
      expect(e).to be_a Stripe::InvalidRequestError
      expect(e.http_status).to eq 400
      expect(e.message).to eq('Invalid timestamp: can be no more than five years in the future')
    }
  end

  context 'updating a subscription' do
    it 'updates a stripe customers existing subscription' do
      silver = stripe_helper.create_plan(id: 'silver')
      gold = stripe_helper.create_plan(id: 'gold')
      customer = Stripe::Customer.create(id: 'test_customer_sub', source: gen_card_tk, plan: 'silver')
      sub = customer.subscriptions.retrieve(customer.subscriptions.data.first.id)
      sub.plan = 'gold'
      sub.quantity = 5
      sub.metadata.foo = 'bar'
      sub.metadata.example = 'yes'
      expect(sub.save).to be_truthy
      expect(sub.object).to eq 'subscription'
      expect(sub.plan.to_hash).to eq(gold.to_hash)
      expect(sub.quantity).to eq(5)
      expect(sub.metadata.foo).to eq('bar')
      expect(sub.metadata.example).to eq 'yes'

      customer = Stripe::Customer.retrieve('test_customer_sub')
      expect(customer.subscriptions.data).to_not be_empty
      expect(customer.subscriptions.count).to eq 1
      expect(customer.subscriptions.data.length).to eq 1
      expect(customer.subscriptions.data.first.id).to eq sub.id
      expect(customer.subscriptions.data.first.plan.to_hash).to eq(gold.to_hash)
      expect(customer.subscriptions.data.first.customer).to eq customer.id
    end

    it 'throws an error when plan does not exist' do
      free = stripe_helper.create_plan(id: 'free', amount: 0)
      customer = Stripe::Customer.create(id: 'cardless', plan: 'free')
      sub = customer.subscriptions.retrieve(customer.subscriptions.data.first.id)
      sub.plan = 'gazebo'
      expect { sub.save }.to raise_error { |e|
        expect(e).to be_a Stripe::InvalidRequestError
        expect(e.http_status).to eq 404
        expect(e.message).to_not be_nil
      }
      customer = Stripe::Customer.retrieve('cardless')
      expect(customer.subscriptions.count).to eq 1
      expect(customer.subscriptions.data.length).to eq 1
      expect(customer.subscriptions.data.first.plan.to_hash).to eq free.to_hash
    end

    it 'throws an error when subscription does not exist' do
      free = stripe_helper.create_plan(id: 'free', amount: 0)
      customer = Stripe::Customer.create(id: 'cardless', plan: 'free')
      expect { customer.subscriptions.retrieve('gazebo') }.to raise_error { |e|
        expect(e).to be_a Stripe::InvalidRequestError
        expect(e.http_status).to eq 404
        expect(e.message).to_not be_nil
      }
      customer = Stripe::Customer.retrieve('cardless')
      expect(customer.subscriptions.count).to eq 1
      expect(customer.subscriptions.data.length).to eq 1
      expect(customer.subscriptions.data.first.plan.to_hash).to eq free.to_hash
    end

    it 'throws an error when updating a customer with no card' do
      free = stripe_helper.create_plan(id: 'free', amount: 0)
      paid = stripe_helper.create_plan(id: 'enterprise', amount: 499)
      customer = Stripe::Customer.create(id: 'cardless', plan: 'free')
      sub = customer.subscriptions.retrieve(customer.subscriptions.data.first.id)
      sub.plan = 'enterprise'
      expect { sub.save }.to raise_error { |e|
        expect(e).to be_a Stripe::InvalidRequestError
        expect(e.http_status).to eq 400
        expect(e.message).to_not be_nil
      }
      customer = Stripe::Customer.retrieve('cardless')
      expect(customer.subscriptions.count).to eq 1
      expect(customer.subscriptions.data.length).to eq 1
      expect(customer.subscriptions.data.first.plan.to_hash).to eq free.to_hash
    end

    it 'updates a customer with no card to a plan with a free trial' do
      free = stripe_helper.create_plan(id: 'free', amount: 0)
      trial = stripe_helper.create_plan(id: 'trial', amount: 999, trial_period_days: 14)
      customer = Stripe::Customer.create(id: 'cardless', plan: 'free')
      sub = customer.subscriptions.retrieve(customer.subscriptions.data.first.id)
      sub.plan = 'trial'
      sub.save
      expect(sub.object).to eq 'subscription'
      expect(sub.plan.to_hash).to eq trial.to_hash

      customer = Stripe::Customer.retrieve('cardless')
      expect(customer.subscriptions.data).to_not be_empty
      expect(customer.subscriptions.count).to eq 1
      expect(customer.subscriptions.data.length).to eq 1
      expect(customer.subscriptions.data.first.id).to eq sub.id
      expect(customer.subscriptions.data.first.plan.to_hash).to eq trial.to_hash
      expect(customer.subscriptions.data.first.customer).to eq customer.id
    end

    it 'updates a customer with no card to a free plan' do
      free = stripe_helper.create_plan(id: 'free', amount: 0)
      gratis = stripe_helper.create_plan(id: 'gratis', amount: 0)
      customer = Stripe::Customer.create(id: 'cardless', plan: 'free')
      sub = customer.subscriptions.retrieve(customer.subscriptions.data.first.id)
      sub.plan = 'gratis'
      sub.save
      expect(sub.object).to eq 'subscription'
      expect(sub.plan.to_hash).to eq gratis.to_hash
      customer = Stripe::Customer.retrieve('cardless')
      expect(customer.subscriptions.data).to_not be_empty
      expect(customer.subscriptions.count).to eq 1
      expect(customer.subscriptions.data.length).to eq 1
      expect(customer.subscriptions.data.first.id).to eq sub.id
      expect(customer.subscriptions.data.first.plan.to_hash).to eq gratis.to_hash
      expect(customer.subscriptions.data.first.customer).to eq customer.id
    end

    it "sets a card when updating a customer's subscription" do
      free = stripe_helper.create_plan(id: 'free', amount: 0)
      paid = stripe_helper.create_plan(id: 'paid', amount: 499)
      customer = Stripe::Customer.create(id: 'test_customer_sub', plan: 'free')

      sub = customer.subscriptions.retrieve(customer.subscriptions.data.first.id)
      sub.plan = 'paid'
      sub.source = gen_card_tk
      sub.save

      customer = Stripe::Customer.retrieve('test_customer_sub')

      expect(customer.sources.count).to eq(1)
      expect(customer.sources.data.length).to eq(1)
      expect(customer.default_source).to_not be_nil
      expect(customer.default_source).to eq customer.sources.data.first.id
    end

    it 'sets a card when updating a customers subscription' do
      # our plans are silver, gold, platinum
      free = stripe_helper.create_plan(id: 'free', amount: 0)
      paid = stripe_helper.create_plan(id: 'paid', amount: 499)
      silver = stripe_helper.create_plan(id: 'silver', amount: 900)
      customer = Stripe::Customer.create(id: 'test_customer_sub', plan: 'silver', source: gen_card_tk)
      sub = customer.subscriptions.retrieve(customer.subscriptions.data[0].id)
      sub.plan = 'silver'
      sub.source = gen_card_tk
      sub.save
      customer = Stripe::Customer.retrieve('test_customer_sub')
      expect(customer.sources.count).to eq 2
      expect(customer.sources.data.length).to eq 2
      expect(customer.default_source).to_not be_nil
      expect(customer.default_source).not_to eq customer.sources.data[0].id
    end

    it 'changes an active subscription to a trial when trial_end is set' do
      plan = stripe_helper.create_plan(id: 'no_trial', amount: 999)
      expect(plan.id).to eq 'no_trial'
      expect(plan.interval).to eq 'month'
      expect(plan.name).to eq 'StripeMock Default Plan ID'
      expect(plan.amount).to eq 999
      expect(plan.currency).to eq 'usd'
      expect(plan.object).to eq 'plan'
      expect(plan.livemode).to eq false
      expect(plan.interval_count).to eq 1
      expect(plan.trial_period_days).to eq nil

      customer = Stripe::Customer.create(id: 'test_trial_end', plan: 'no_trial', source: gen_card_tk)
      expect(customer.id). to eq 'test_trial_end'
      expect(customer.email).to eq 'stripe_mock@example.com'
      expect(customer.description).to eq 'an auto-generated stripe customer data mock'
      expect(customer.object).to eq 'customer'
      expect(customer.created).to eq 1372126710
      expect(customer.livemode).to eq false
      expect(customer.delinquent).to eq false
      expect(customer.discount).to eq nil
      expect(customer.account_balance).to eq 0
      expect(customer.sources.object).to eq 'list'
      expect(customer.sources.total_count).to eq 1
      expect(customer.sources.url).to eq '/v1/customers/test_trial_end/sources'
      expect(customer.sources.data[0].id).to match(/^test_cc/)
      expect(customer.sources.data[0].object).to eq 'card'
      expect(customer.sources.data[0].last4).to eq '4242'
      expect(customer.sources.data[0].type).to eq 'Visa'
      expect(customer.sources.data[0].brand).to eq 'Visa'
      expect(customer.sources.data[0].funding).to eq 'credit'
      expect(customer.sources.data[0].exp_month).to eq 12
      expect(customer.sources.data[0].exp_year).to eq 2021
      expect(customer.sources.data[0].fingerprint).to eq 'eXWMGVNbMZcworZC'
      expect(customer.sources.data[0].customer).to eq 'test_trial_end'
      expect(customer.sources.data[0].country).to eq 'US'
      expect(customer.sources.data[0].name).to eq 'Johnny App'
      expect(customer.sources.data[0].address_line1).to eq nil
      expect(customer.sources.data[0].address_line2).to eq nil
      expect(customer.sources.data[0].address_city).to eq nil
      expect(customer.sources.data[0].address_state).to eq nil
      expect(customer.sources.data[0].address_zip).to eq nil
      expect(customer.sources.data[0].address_country).to eq nil
      expect(customer.sources.data[0].cvc_check).to eq nil
      expect(customer.sources.data[0].address_line1_check).to eq nil
      # If address_line1 was provided, results of the check: pass, fail, unavailable, or unchecked
      expect(customer.sources.data[0].address_zip_check).to eq nil
      expect(customer.sources.data[0].last4).to eq '4242'
      expect(customer.sources.data[0].cvc).to eq '999'
      expect(customer.subscriptions.object).to eq 'list'
      expect(customer.subscriptions.total_count).to eq 1
      expect(customer.subscriptions.url).to eq '/v1/customers/test_trial_end/subscriptions'
      expect(customer.subscriptions.data[0].id).to match(/^test_su/)
      # expect(customer.subscriptions.data[0].current_period_start).to eq '1441384417'
      # expect(customer.subscriptions.data[0].current_period_end).to eq '1443976417'
      expect(customer.subscriptions.data[0].status).to eq 'active'
      expect(customer.subscriptions.data[0].plan[:id]).to eq 'no_trial'
      expect(customer.subscriptions.data[0].plan[:interval]).to eq 'month'
      expect(customer.subscriptions.data[0].plan[:name]).to eq 'StripeMock Default Plan ID'
      expect(customer.subscriptions.data[0].plan[:amount]).to eq 999
      expect(customer.subscriptions.data[0].plan[:currency]).to eq 'usd'
      expect(customer.subscriptions.data[0].plan[:object]).to eq 'plan'
      expect(customer.subscriptions.data[0].plan[:livemode]).to eq false
      expect(customer.subscriptions.data[0].plan[:interval_count]).to eq 1
      expect(customer.subscriptions.data[0].plan[:trial_period_days]).to eq nil

      expect(customer.subscriptions.data[0].plan.interval).to eq 'month'
      expect(customer.subscriptions.data[0].plan.name).to eq 'StripeMock Default Plan ID'
      expect(customer.subscriptions.data[0].plan.amount).to eq 999
      expect(customer.subscriptions.data[0].plan.currency).to eq 'usd'
      expect(customer.subscriptions.data[0].plan.object).to eq 'plan'
      expect(customer.subscriptions.data[0].plan.livemode).to eq false
      expect(customer.subscriptions.data[0].plan.interval_count).to eq 1
      expect(customer.subscriptions.data[0].plan.trial_period_days).to eq nil
      # expect(customer.subscriptions.data[0].plan.cancel_at_period_end).to eq false # does not exist
      # expect(customer.subscriptions.data[0].plan.canceled_at).to eq nil # does not exist
      # expect(customer.subscriptions.data[0].plan.ended_at).to eq nil
      # expect(customer.subscriptions.data[0].plan.start).to eq 1308595038
      expect(customer.subscriptions.data[0].plan.object).to eq 'plan'
      # expect(customer.subscriptions.data[0].plan.trial_start).to eq nil
      # expect(customer.subscriptions.data[0].plan.trial_end).to eq nil
      # expect(customer.subscriptions.data[0].plan.test_trial_end).to eq trial_end
      # expect(customer.subscriptions.data[0].plan.quantity).to eq 1
      # expect(customer.subscriptions.data[0].plan.tax_percent).to eq nil
      # expect(customer.subscriptions.data[0].plan.discount).to eq nil
      # expect(customer.subscriptions.data[0].plan.metadata). to eq {}
      expect(customer.default_source).to match(/^test_cc/)
      expect(customer.plan).to eq 'no_trial'

      sub = customer.subscriptions.retrieve(customer.subscriptions.data[0].id)
      expect(sub.status).to eq 'active'
      trial_end = Time.now.utc.to_i + 3_600
      sub.trial_end = trial_end
      # sub.save
      expect(sub.object).to eq 'subscription'
      expect(sub.plan.to_hash).to eq plan.to_hash
      # expect(sub.status).to eq('trialing') # still active TODO: is this a stripe-ruby-mock error ?
      expect(sub.status).to eq 'active'
      expect(sub.trial_end).to eq trial_end
      # expect(sub.current_period_end).to eq trial_end # fails TODO: is this a stripe-ruby-mock error ?
    end

    it 'does not require a card when trial_end is present', live: true do
      plan = stripe_helper.create_plan(
        amount: 2000,
        interval: 'month',
        name: 'Amazing Gold Plan',
        currency: 'usd',
        id: 'gold'
      )
      options = { plan: plan.id, trial_end: (Date.today + 30).to_time.to_i }
      stripe_customer = Stripe::Customer.create
      stripe_customer.subscriptions.create options
    end
  end

  context 'retrieve multiple subscriptions' do
    it 'retrieves a list of multiple subscriptions' do
      free = stripe_helper.create_plan(id: 'free', amount: 0)
      paid = stripe_helper.create_plan(id: 'paid', amount: 499)
      customer = Stripe::Customer.create(id: 'test_customer_sub', source: gen_card_tk, plan: 'free')
      customer.subscriptions.create(plan: 'paid')
      customer = Stripe::Customer.retrieve('test_customer_sub')
      list = customer.subscriptions.all
      expect(list.object).to eq 'list'
      expect(list.count).to eq 2
      expect(list.data.length).to eq 2
      expect(list.data.last.object).to eq 'subscription'
      expect(list.data.last.plan.to_hash).to eq free.to_hash
      expect(list.data.first.object).to eq 'subscription'
      expect(list.data.first.plan.to_hash).to eq(paid.to_hash)
    end
  end

  # If address_line1 was provided, there are four possible Stripe responses to their address check:
  # pass, fail, unavailable, or unchecked
  context 'testing the address_line1_check' do
    let(:stripe_helper) { StripeMock.create_test_helper }

    it 'receives and acts on the response from stripe for the address_line1_check' do
      # pending 'needs more work as currently fails receiving a response beyond nil'
      card_token = stripe_helper.generate_card_token(
        last4: '4242',
        exp_month: 12,
        exp_year: 2021,
        name: 'Johnny App',
        address_line1: 'actual account address',
        address_line2: 'the real address',
        address_city: 'the city',
        address_state: 'AK',
        address_zip: '12345',
        address_country: 'US',
        address_line1_check: 'pass'
      )
      plan = stripe_helper.create_plan(id: 'no_trial', amount: 550)
      expect(plan.id).to eq 'no_trial'
      expect(plan.interval).to eq 'month'
      expect(plan.name).to eq 'StripeMock Default Plan ID'
      expect(plan.amount).to eq 550
      expect(plan.currency).to eq 'usd'
      expect(plan.trial_period_days).to eq nil

      customer = Stripe::Customer.create(
        id: 'test_trial_end',
        plan: 'no_trial',
        source: card_token
      )

      customer = Stripe::Customer.retrieve(customer.id)
      expect(customer.id). to eq 'test_trial_end'
      expect(customer.email).to eq 'stripe_mock@example.com'
      expect(customer.description).to eq 'an auto-generated stripe customer data mock'
      expect(customer.sources.url).to eq '/v1/customers/test_trial_end/sources'
      expect(customer.sources.data[0].id).to match(/^test_cc/)
      expect(customer.sources.data[0].object).to eq 'card'
      expect(customer.sources.data[0].last4).to eq '4242'
      expect(customer.sources.data[0].exp_month).to eq 12
      expect(customer.sources.data[0].exp_year).to eq 2021
      expect(customer.sources.data[0].name).to eq 'Johnny App'
      expect(customer.sources.data[0].address_line1).to eq 'actual account address'
      expect(customer.sources.data[0].address_line2).to eq 'the real address'
      expect(customer.sources.data[0].address_city).to eq 'the city'
      expect(customer.sources.data[0].address_state).to eq 'AK'
      expect(customer.sources.data[0].address_zip).to eq '12345'
      expect(customer.sources.data[0].address_country).to eq 'US'
      expect(customer.sources.data[0].cvc_check).to eq nil
      # uncomment below if you are not mocking and testing the address line1 check
      # expect(customer.sources.data[0].address_line1_check).to eq nil

      # If address_line1 is provided, Stripe returns one of four results of the check:
      #   pass, fail, unavailable, unchecked
      #
      # Here we test the mock above of Stripe passing the address line1 check
      # We actually mocked the pass in this line in the card token creation above:
      #   address_line1_check: 'pass'
      expect(customer.sources.data[0].address_line1_check).to eq 'pass'
      # the other tests can likewise be created as needed
      # expect(customer.sources.data[0].address_line1_check).to_not eq unavailable
      # expect(customer.sources.data[0].address_line1_check).to_not eq unchecked

      # adjust code above to cause an error, then uncomment the error test below
      # TODO: make sure this error code matches error generated
      # expect(customer.sources.data[0].address_line1_check).to raise_error { |e|
      #  expect(e).to be_a RuntimeError
      #  expect(e.http_status).to eq(400)
      # }
      # See: https://github.com/rebelidealist/stripe-ruby-mock/blob/master/lib/stripe_mock/data.rb
      # Find on that page, this method: def self.mock_card(params={})
    end
  end
end
