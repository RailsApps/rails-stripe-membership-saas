Stripe.api_key = ENV["STRIPE_API_KEY"]
STRIPE_PUBLISHABLE_KEY = ENV["STRIPE_PUBLISHABLE_KEY"]

# Note: do not listen for customer.subscription.updated
# Reference : http://imzank.com/2012/11/how-to-use-stripe-com-to-email-your-customers/

# changed from setup to configure : 20140214
# Reference : https://github.com/RailsApps/rails-stripe-membership-saas/issues/96#issuecomment-35108722
StripeEvent.configure do |events|
  events.subscribe 'customer.subscription.deleted' do |event|
    StripeEvent.event_retriever = lambda do |params|
      verified_event = Stripe::Event.retrieve(params[event.id])
          
      user = User.where(customer_id: verified_event.data.object.customer)
      user.expire
    end
  end

  events.subscribe 'customer.charge.succeeded' do |event|
    StripeEvent.event_retriever = lambda do |params|
      verified_event = Stripe::Event.retrieve(params[event.id])
          
      user = User.where(customer_id: verified_event.data.object.customer)
      user.thanks
    end
  end

  events.subscribe 'transfer.created' do |event|
    StripeEvent.event_retriever = lambda do |params|
      verified_event = Stripe::Event.retrieve(params[event.id])
        
      user = User.where(customer_id: verified_event.data.object.customer)
      owner = User.first
      user.transfer_created
    end
  end
  
  events.subscribe 'customer.subscription.updated' do |event|
    StripeEvent.event_retriever = lambda do |params|
      verified_event = Stripe::Event.retrieve(params[event.id])
          
      user = User.where(customer_id: verified_event.data.object.customer)
      user.plan_changed
    end
  end
end