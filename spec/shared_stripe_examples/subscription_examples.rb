# https://github.com/rebelidealist/stripe-ruby-mock
require 'stripe_mock'
require 'stripe_mock/server'
require 'pry'

# this test file is not yet ready for prime time, still more work to be done
include Warden::Test::Helpers
Warden.test_mode!

# shared_examples

RSpec.configure do
  def card
    card = stripe_helper.generate_card_token(last4: '4242')
  end
end

  describe "Customer Subscriptions" do

    let(:stripe_helper) { StripeMock.create_test_helper }

    before(:each) do
      StripeMock.start
      @attr = {
        name: "Test User",
        email: "test@example.com",
        password: "changeme",
        password_confirmation: "changeme"
      }
    end

    after(:each) do
      StripeMock.stop
      Warden.test_reset!
    end

    context "creating a new subscription" do

    it "adds a new subscription to customer with none" do # 20150627 passing
      plan = stripe_helper.create_plan(id: 'five', name: 'Five', amount: 500, interval: 'month', source: card)
      customer = Stripe::Customer.create(plan: plan.id, source: card)
      expect(customer.subscriptions.data).to_not be_empty
      customer.subscriptions {include=data}
      expect(customer.subscriptions.data.first.status).to eq('active')
      expect(customer.subscriptions.data.first[:id]).to match /^test_su_/
      expect(customer.subscriptions.data.count).to eq(1)
      sub = customer.subscriptions.create({ plan: 'five', metadata: { foo: "bar", example: "yes" } })
      expect(sub.object).to eq('subscription')
      expect(sub.plan.to_hash).to eq(plan.to_hash)
      expect(sub.metadata.foo).to eq( "bar" )
      expect(sub.metadata.example).to eq( "yes" )
      customer = Stripe::Customer.retrieve(customer.id)
      expect(customer.subscriptions.data).to_not be_empty
      expect(customer.subscriptions.count).to eq(2)
      expect(customer.subscriptions.data.length).to eq(2)
      expect(customer.subscriptions.data.first.id).to eq(sub.id)
      expect(customer.subscriptions.data.first.plan.to_hash).to eq(plan.to_hash)
      expect(customer.subscriptions.data.first.customer).to eq(customer.id)
      expect(customer.subscriptions.data.first.metadata.foo).to eq( "bar" )
      expect(customer.subscriptions.data.first.metadata.example).to eq( "yes" )
    end

    it "adds additional subscription to customer with existing subscription" do
      silver = stripe_helper.create_plan(id: 'silver')
      gold = stripe_helper.create_plan(id: 'gold')
      customer = Stripe::Customer.create(id: 'test_customer_sub', source: card, plan: 'gold')
      sub = customer.subscriptions.create({ plan: 'silver' })
      expect(sub.object).to eq('subscription')
      expect(sub.plan.to_hash).to eq(silver.to_hash)
      customer = Stripe::Customer.retrieve('test_customer_sub')
      expect(customer.subscriptions.data).to_not be_empty
      expect(customer.subscriptions.count).to eq(2)
      expect(customer.subscriptions.data.length).to eq(2)
      expect(customer.subscriptions.data.last.plan.to_hash).to eq(gold.to_hash)
      expect(customer.subscriptions.data.last.customer).to eq(customer.id)
      expect(customer.subscriptions.data.first.id).to eq(sub.id)
      expect(customer.subscriptions.data.first.plan.to_hash).to eq(silver.to_hash)
      expect(customer.subscriptions.data.first.customer).to eq(customer.id)
    end

    it "subscribes a cardless customer when specifing a card token" do
      plan = stripe_helper.create_plan(id: 'enterprise', amount: 499, source: card)
      customer = Stripe::Customer.create(id: 'cardless')
      sub = customer.subscriptions.create(plan: 'enterprise', source: card)
      customer = Stripe::Customer.retrieve('cardless')
      expect(customer.subscriptions.data.first.id).to eq(sub.id)
      expect(customer.subscriptions.data.first.customer).to eq(customer.id)
      expect(customer.sources.count).to eq(1)
      expect(customer.sources.data.length).to eq(1)
      expect(customer.default_source).to_not be_nil
      expect(customer.default_source).to eq customer.sources.data.first.id
    end

    it "throws an error when plan does not exist" do
      customer = Stripe::Customer.create(id: 'cardless')
      expect { customer.subscriptions.create({ plan: 'gazebo' }) }.to raise_error { |e|
        expect(e).to be_a Stripe::InvalidRequestError
        expect(e.http_status).to eq(404)
        expect(e.message).to_not be_nil
        }
      expect(customer.subscriptions.data).to be_empty
      expect(customer.subscriptions.count).to eq(0)
    end

    it "throws an error when subscribing a customer with no card" do
      plan = stripe_helper.create_plan(id: 'enterprise', amount: 499)
      customer = Stripe::Customer.create(id: 'cardless')
      expect { customer.subscriptions.create({ plan: 'enterprise' }) }.to raise_error { |e|
        expect(e).to be_a Stripe::InvalidRequestError
        expect(e.http_status).to eq(400)
        expect(e.message).to_not be_nil
        }
      expect(customer.subscriptions.data).to be_empty
      expect(customer.subscriptions.count).to eq(0)
    end

    context "cancelling a subscription" do

    it "cancels a stripe customer's subscription", live: true do
      truth = stripe_helper.create_plan(id: 'the truth')
      customer = Stripe::Customer.create(source: card, plan: "the truth")
      sub = customer.subscriptions.retrieve(customer.subscriptions.data.first.id)
      result = sub.delete
      expect(result.status).to eq('canceled')
      expect(result.cancel_at_period_end).to eq false
      expect(result.canceled_at).to_not be_nil
      expect(result.id).to eq(sub.id)
      customer = Stripe::Customer.retrieve(customer.id)
      expect(customer.subscriptions.data).to be_empty
      expect(customer.subscriptions.count).to eq(0)
      expect(customer.subscriptions.data.length).to eq(0)
    end

    it "retrieves an empty list if there's no subscriptions" do
      Stripe::Customer.create(id: 'no_subs')
      customer = Stripe::Customer.retrieve('no_subs')
      list = customer.subscriptions.all
      expect(list.object).to eq("list")
      expect(list.count).to eq(0)
      expect(list.data.length).to eq(0)
    end
  end

  describe "metadata" do
    it "creates a stripe customer and subscribes them to a plan with meta data", live: true do
    stripe_helper.create_plan(
      amount: 500,
      interval: 'month',
      name: 'Sample Plan',
      currency: 'usd',
      id: 'Sample5',
      statement_description: "Plan Statement"
      )
    customer = Stripe::Customer.create({
      email: 'johnny@appleseed.com',
      source: stripe_helper.generate_card_token
      })
    subscription = customer.subscriptions.create(plan: "Sample5")
    subscription.metadata['foo'] = 'bar'
    expect(subscription.save).to be_a Stripe::Subscription
    customer = Stripe::Customer.retrieve(customer.id)
    expect(customer.email).to eq('johnny@appleseed.com')
    expect(customer.subscriptions.first.plan.id).to eq('Sample5')
    expect(customer.subscriptions.first.metadata['foo']).to eq('bar')
    end
  end

  it "resumes an at period end cancelled subscription" do
    truth = stripe_helper.create_plan(id: 'the_truth')
   #customer = Stripe::Customer.create(id: 'test_customer_sub', card: card, plan: "the_truth")
    customer = Stripe::Customer.create(id: 'test_customer_sub', source: card, plan: "the_truth")
    sub = customer.subscriptions.retrieve(customer.subscriptions.data.first.id)
    result = sub.delete(at_period_end: true)
    sub.plan = 'the_truth'
    sub.save
    customer = Stripe::Customer.retrieve('test_customer_sub')
    expect(customer.subscriptions.data).to_not be_empty
    expect(customer.subscriptions.count).to eq(1)
    expect(customer.subscriptions.data.length).to eq(1)
    expect(customer.subscriptions.data.first.status).to eq('active')
    expect(customer.subscriptions.data.first.cancel_at_period_end).to eq(false)
    expect(customer.subscriptions.data.first.ended_at).to be_nil
    expect(customer.subscriptions.data.first.canceled_at).to be_nil
  end
end

=begin
it "cancels a stripe customer's subscription at period end" do
truth = stripe_helper.create_plan(id: 'the_truth')
customer = Stripe::Customer.create(id: 'test_customer_sub', card: card, plan: "the_truth")
sub = customer.subscriptions.retrieve(customer.subscriptions.data.first.id)
result = sub.delete(at_period_end: true)
expect(result.status).to eq('active')
expect(result.cancel_at_period_end).to eq(true)
expect(result.id).to eq(sub.id)
customer = Stripe::Customer.retrieve('test_customer_sub')
expect(customer.subscriptions.data).to_not be_empty
expect(customer.subscriptions.count).to eq(1)
expect(customer.subscriptions.data.length).to eq(1)
expect(customer.subscriptions.data.first.status).to eq('active')
expect(customer.subscriptions.data.first.cancel_at_period_end).to eq(true)
expect(customer.subscriptions.data.first.ended_at).to be_nil
expect(customer.subscriptions.data.first.canceled_at).to_not be_nil
end
=end

=begin
it "subscribes a customer with no card to a plan with a free trial" do
plan = stripe_helper.create_plan(id: 'trial', amount: 999, trial_period_days: 14)
customer = Stripe::Customer.create(id: 'cardless')
sub = customer.subscriptions.create({ plan: 'trial' })
expect(sub.object).to eq('subscription')
expect(sub.plan.to_hash).to eq(plan.to_hash)
expect(sub.trial_end - sub.trial_start).to eq(14 * 86400)
customer = Stripe::Customer.retrieve('cardless')
expect(customer.subscriptions.data).to_not be_empty
expect(customer.subscriptions.count).to eq(1)
expect(customer.subscriptions.data.length).to eq(1)
expect(customer.subscriptions.data.first.id).to eq(sub.id)
expect(customer.subscriptions.data.first.plan.to_hash).to eq(plan.to_hash)
expect(customer.subscriptions.data.first.customer).to eq(customer.id)
end
=end
=begin
it "subscribes a customer with no card to a free plan" do
plan = stripe_helper.create_plan(id: 'free_tier', amount: 0)
customer = Stripe::Customer.create(id: 'cardless')
sub = customer.subscriptions.create({ plan: 'free_tier' })
expect(sub.object).to eq('subscription')
expect(sub.plan.to_hash).to eq(plan.to_hash)
customer = Stripe::Customer.retrieve('cardless')
expect(customer.subscriptions.data).to_not be_empty
expect(customer.subscriptions.count).to eq(1)
expect(customer.subscriptions.data.length).to eq(1)
expect(customer.subscriptions.data.first.id).to eq(sub.id)
expect(customer.subscriptions.data.first.plan.to_hash).to eq(plan.to_hash)
expect(customer.subscriptions.data.first.customer).to eq(customer.id)
end
=end
=begin
it "overrides trial length when trial end is set" do
plan = stripe_helper.create_plan(id: 'trial', amount: 999, trial_period_days: 14)
customer = Stripe::Customer.create(id: 'short_trial')
trial_end = Time.now.utc.to_i + 3600
sub = customer.subscriptions.create({ plan: 'trial', trial_end: trial_end })
expect(sub.object).to eq('subscription')
expect(sub.plan.to_hash).to eq(plan.to_hash)
expect(sub.current_period_end).to eq(trial_end)
expect(sub.trial_end).to eq(trial_end)
end
=end
=begin
it "returns without a trial when trial_end is set to 'now'" do
plan = stripe_helper.create_plan(id: 'trial', amount: 999, trial_period_days: 14)
customer = Stripe::Customer.create(id: 'no_trial', card: stripe_helper.generate_card_token)
sub = customer.subscriptions.create({ plan: 'trial', trial_end: "now" })
expect(sub.object).to eq('subscription')
expect(sub.plan.to_hash).to eq(plan.to_hash)
expect(sub.status).to eq('active')
expect(sub.trial_start).to be_nil
expect(sub.trial_end).to be_nil
end
=end
=begin
it "raises error when trial_end is not an integer or 'now'" do
plan = stripe_helper.create_plan(id: 'trial', amount: 999, trial_period_days: 14)
customer = Stripe::Customer.create(id: 'cus_trial')
expect { customer.subscriptions.create({ plan: 'trial', trial_end: "gazebo" }) }.to raise_error {|e|
expect(e).to be_a Stripe::InvalidRequestError
expect(e.http_status).to eq(400)
expect(e.message).to eq("Invalid timestamp: must be an integer")
}
end
=end
=begin
it "raises error when trial_end is set to a time in the past" do
plan = stripe_helper.create_plan(id: 'trial', amount: 999, trial_period_days: 14)
customer = Stripe::Customer.create(id: 'past_trial')
trial_end = Time.now.utc.to_i - 3600
expect { customer.subscriptions.create({ plan: 'trial', trial_end: trial_end }) }.to raise_error {|e|
expect(e).to be_a Stripe::InvalidRequestError
expect(e.http_status).to eq(400)
expect(e.message).to eq("Invalid timestamp: must be an integer Unix timestamp in the future")
}
end
=end
=begin
it "raises error when trial_end is set to a time more than five years in the future" do
plan = stripe_helper.create_plan(id: 'trial', amount: 999, trial_period_days: 14)
customer = Stripe::Customer.create(id: 'long_trial')
trial_end = Time.now.utc.to_i + 31557600*5 + 3600 # 5 years + 1 hour
expect { customer.subscriptions.create({ plan: 'trial', trial_end: trial_end }) }.to raise_error {|e|
expect(e).to be_a Stripe::InvalidRequestError
expect(e.http_status).to eq(400)
expect(e.message).to eq("Invalid timestamp: can be no more than five years in the future")
}
end
=end
#TODO study this one some more
=begin
context "updating a subscription" do
it "updates a stripe customer's existing subscription" do
silver = stripe_helper.create_plan(id: 'silver')
gold = stripe_helper.create_plan(id: 'gold')
customer = Stripe::Customer.create(id: 'test_customer_sub', card: card, plan: 'silver')
sub = customer.subscriptions.retrieve(customer.subscriptions.data.first.id)
sub.plan = 'gold'
sub.quantity = 5
sub.metadata.foo = "bar"
sub.metadata.example = "yes"
expect(sub.save).to be_truthy
expect(sub.object).to eq('subscription')
expect(sub.plan.to_hash).to eq(gold.to_hash)
expect(sub.quantity).to eq(5)
expect(sub.metadata.foo).to eq( "bar" )
expect(sub.metadata.example).to eq( "yes" )
customer = Stripe::Customer.retrieve('test_customer_sub')
expect(customer.subscriptions.data).to_not be_empty
expect(customer.subscriptions.count).to eq(1)
expect(customer.subscriptions.data.length).to eq(1)
expect(customer.subscriptions.data.first.id).to eq(sub.id)
expect(customer.subscriptions.data.first.plan.to_hash).to eq(gold.to_hash)
expect(customer.subscriptions.data.first.customer).to eq(customer.id)
end
=end
# TODO study this some more
=begin
it "throws an error when plan does not exist" do
free = stripe_helper.create_plan(id: 'free', amount: 0)
customer = Stripe::Customer.create(id: 'cardless', plan: 'free')
sub = customer.subscriptions.retrieve(customer.subscriptions.data.first.id)
sub.plan = 'gazebo'
expect { sub.save }.to raise_error {|e|
expect(e).to be_a Stripe::InvalidRequestError
expect(e.http_status).to eq(404)
expect(e.message).to_not be_nil
}
customer = Stripe::Customer.retrieve('cardless')
expect(customer.subscriptions.count).to eq(1)
expect(customer.subscriptions.data.length).to eq(1)
expect(customer.subscriptions.data.first.plan.to_hash).to eq(free.to_hash)
end
=end
#TODO this one should work 
=begin
it "throws an error when subscription does not exist" do
free = stripe_helper.create_plan(id: 'free', amount: 0)
customer = Stripe::Customer.create(id: 'cardless', plan: 'free')
expect { customer.subscriptions.retrieve("gazebo") }.to raise_error {|e|
expect(e).to be_a Stripe::InvalidRequestError
expect(e.http_status).to eq(404)
expect(e.message).to_not be_nil
}
customer = Stripe::Customer.retrieve('cardless')
expect(customer.subscriptions.count).to eq(1)
expect(customer.subscriptions.data.length).to eq(1)
expect(customer.subscriptions.data.first.plan.to_hash).to eq(free.to_hash)
end
=end
=begin
it "throws an error when updating a customer with no card" do
free = stripe_helper.create_plan(id: 'free', amount: 0)
paid = stripe_helper.create_plan(id: 'enterprise', amount: 499)
customer = Stripe::Customer.create(id: 'cardless', plan: 'free')
sub = customer.subscriptions.retrieve(customer.subscriptions.data.first.id)
sub.plan = 'enterprise'
expect { sub.save }.to raise_error {|e|
expect(e).to be_a Stripe::InvalidRequestError
expect(e.http_status).to eq(400)
expect(e.message).to_not be_nil
}
customer = Stripe::Customer.retrieve('cardless')
expect(customer.subscriptions.count).to eq(1)
expect(customer.subscriptions.data.length).to eq(1)
expect(customer.subscriptions.data.first.plan.to_hash).to eq(free.to_hash)
end
=end
#TODO study this some more 
=begin
it "updates a customer with no card to a plan with a free trial" do
free = stripe_helper.create_plan(id: 'free', amount: 0)
trial = stripe_helper.create_plan(id: 'trial', amount: 999, trial_period_days: 14)
customer = Stripe::Customer.create(id: 'cardless', plan: 'free')
sub = customer.subscriptions.retrieve(customer.subscriptions.data.first.id)
sub.plan = 'trial'
sub.save
expect(sub.object).to eq('subscription')
expect(sub.plan.to_hash).to eq(trial.to_hash)
customer = Stripe::Customer.retrieve('cardless')
expect(customer.subscriptions.data).to_not be_empty
expect(customer.subscriptions.count).to eq(1)
expect(customer.subscriptions.data.length).to eq(1)
expect(customer.subscriptions.data.first.id).to eq(sub.id)
expect(customer.subscriptions.data.first.plan.to_hash).to eq(trial.to_hash)
expect(customer.subscriptions.data.first.customer).to eq(customer.id)
end
=end
=begin
it "updates a customer with no card to a free plan" do
free = stripe_helper.create_plan(id: 'free', amount: 0)
gratis = stripe_helper.create_plan(id: 'gratis', amount: 0)
customer = Stripe::Customer.create(id: 'cardless', plan: 'free')
sub = customer.subscriptions.retrieve(customer.subscriptions.data.first.id)
sub.plan = 'gratis'
sub.save
expect(sub.object).to eq('subscription')
expect(sub.plan.to_hash).to eq(gratis.to_hash)
customer = Stripe::Customer.retrieve('cardless')
expect(customer.subscriptions.data).to_not be_empty
expect(customer.subscriptions.count).to eq(1)
expect(customer.subscriptions.data.length).to eq(1)
expect(customer.subscriptions.data.first.id).to eq(sub.id)
expect(customer.subscriptions.data.first.plan.to_hash).to eq(gratis.to_hash)
expect(customer.subscriptions.data.first.customer).to eq(customer.id)
end
=end
#TODO study this more, it is the key to free plan
=begin
it "sets a card when updating a customer's subscription" do
free = stripe_helper.create_plan(id: 'free', amount: 0)
paid = stripe_helper.create_plan(id: 'paid', amount: 499)
customer = Stripe::Customer.create(id: 'test_customer_sub', plan: 'free')
sub = customer.subscriptions.retrieve(customer.subscriptions.data.first.id)
sub.plan = 'paid'
sub.card = card
sub.save
customer = Stripe::Customer.retrieve('test_customer_sub')
expect(customer.sources.count).to eq(1)
expect(customer.sources.data.length).to eq(1)
expect(customer.default_source).to_not be_nil
expect(customer.default_source).to eq customer.sources.data.first.id
end
=end
=begin
it "overrides trial length when trial end is set" do
plan = stripe_helper.create_plan(id: 'trial', amount: 999, trial_period_days: 14)
customer = Stripe::Customer.create(id: 'test_trial_end', plan: 'trial')
sub = customer.subscriptions.retrieve(customer.subscriptions.data.first.id)
trial_end = Time.now.utc.to_i + 3600
sub.trial_end = trial_end
sub.save
expect(sub.object).to eq('subscription')
expect(sub.trial_end).to eq(trial_end)
expect(sub.current_period_end).to eq(trial_end)
end
=end
=begin
it "returns without a trial when trial_end is set to 'now'" do
plan = stripe_helper.create_plan(id: 'trial', amount: 999, trial_period_days: 14)
customer = Stripe::Customer.create(id: 'test_trial_end', plan: 'trial')
sub = customer.subscriptions.retrieve(customer.subscriptions.data.first.id)
sub.trial_end = "now"
sub.save
expect(sub.object).to eq('subscription')
expect(sub.plan.to_hash).to eq(plan.to_hash)
expect(sub.status).to eq('active')
expect(sub.trial_start).to be_nil
expect(sub.trial_end).to be_nil
end
=end
=begin
it "changes an active subscription to a trial when trial_end is set" do
plan = stripe_helper.create_plan(id: 'no_trial', amount: 999)
customer = Stripe::Customer.create(id: 'test_trial_end', plan: 'no_trial', card: card)
sub = customer.subscriptions.retrieve(customer.subscriptions.data.first.id)
trial_end = Time.now.utc.to_i + 3600
sub.trial_end = trial_end
sub.save
expect(sub.object).to eq('subscription')
expect(sub.plan.to_hash).to eq(plan.to_hash)
expect(sub.status).to eq('trialing')
expect(sub.trial_end).to eq(trial_end)
expect(sub.current_period_end).to eq(trial_end)
end
=end
=begin
it "raises error when trial_end is not an integer or 'now'" do
plan = stripe_helper.create_plan(id: 'no_trial', amount: 999)
customer = Stripe::Customer.create(id: 'test_trial_end', plan: 'no_trial', card: card)
sub = customer.subscriptions.retrieve(customer.subscriptions.data.first.id)
sub.trial_end = "gazebo"
expect { sub.save }.to raise_error {|e|
expect(e).to be_a Stripe::InvalidRequestError
expect(e.http_status).to eq(400)
expect(e.message).to eq("Invalid timestamp: must be an integer")
}
end
end
=end


=begin
it "doesn't change status of subscription when cancelling at period end" do
trial = stripe_helper.create_plan(id: 'trial', trial_period_days: 14)
customer = Stripe::Customer.create(id: 'test_customer_sub', card: card, plan: "trial")
sub = customer.subscriptions.retrieve(customer.subscriptions.data.first.id)
result = sub.delete(at_period_end: true)
expect(result.status).to eq('trialing')
customer = Stripe::Customer.retrieve('test_customer_sub')
expect(customer.subscriptions.data.first.status).to eq('trialing')
end
=end
#TODO worth of study
=begin
it "doesn't require a card when trial_end is present", live: true do
plan = stripe_helper.create_plan({
amount: 2000,
interval: 'month',
name: 'Amazing Gold Plan',
currency: 'usd',
id: 'gold'
})
options = {plan: plan.id, trial_end: (Date.today + 30).to_time.to_i}
stripe_customer = Stripe::Customer.create
stripe_customer.subscriptions.create options
end
=end
=begin
context "retrieve multiple subscriptions" do
it "retrieves a list of multiple subscriptions" do
free = stripe_helper.create_plan(id: 'free', amount: 0)
paid = stripe_helper.create_plan(id: 'paid', amount: 499)
customer = Stripe::Customer.create(id: 'test_customer_sub', card: card, plan: "free")
customer.subscriptions.create({ plan: 'paid' })
customer = Stripe::Customer.retrieve('test_customer_sub')
list = customer.subscriptions.all
expect(list.object).to eq("list")
expect(list.count).to eq(2)
expect(list.data.length).to eq(2)
expect(list.data.last.object).to eq("subscription")
expect(list.data.last.plan.to_hash).to eq(free.to_hash)
expect(list.data.first.object).to eq("subscription")
expect(list.data.first.plan.to_hash).to eq(paid.to_hash)
end
=end
end