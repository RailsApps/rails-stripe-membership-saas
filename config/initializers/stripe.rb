Stripe.api_key = ENV["STRIPE_API_KEY"]
STRIPE_PUBLIC_KEY = ENV["STRIPE_PUBLIC_KEY"]

StripeEvent.setup do
  subscribe 'customer.subscription.deleted' do |event|
    StripeEvent.event_retriever = lambda do |params|
      verified_event = Stripe::Event.retrieve(params[event.id])
          
      user = User.find_by_customer_id(verified_event.data.object.customer)
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