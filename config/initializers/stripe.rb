Stripe.api_key = ENV["STRIPE_API_KEY"]
STRIPE_PUBLIC_KEY = ENV["STRIPE_PUBLIC_KEY"]

# Note: do not listen for customer.subscription.updated
# Reference : http://imzank.com/2012/11/how-to-use-stripe-com-to-email-your-customers/

# Changed StripeEvent#method from setup to configure
# Reference : https://github.com/RailsApps/rails-stripe-membership-saas/issues/96#issuecomment-35108722
StripeEvent.configure do
  subscribe 'customer.subscription.deleted' do |event|
    StripeEvent.event_retriever = lambda do |params|
      verified_event = Stripe::Event.retrieve(params[event.id])
          
     #user = User.find_by_customer_id(verified_event.data.object.customer)
     user = User.where(customer_id: :verified_event.data.object.customer)
      user.expire
    end
  end

  subscribe 'customer.charge.succeeded' do |event|
    StripeEvent.event_retriever = lambda do |params|
      verified_event = Stripe::Event.retrieve(params[event.id])
          
      user = User.find_by_customer_id(verified_event.data.object.customer)
      user.thanks
    end
  end
end