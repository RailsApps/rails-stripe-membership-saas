
def require_stripe_examples
  Dir["./spec/shared_stripe_examples/**/*.rb"].each {|f| require f}
  Dir["./spec/integration_examples/**/*.rb"].each {|f| require f}
end

def it_behaves_like_stripe(&block)
  it_behaves_like 'Account API', &block
  it_behaves_like 'Bank Account Token Mocking', &block
  it_behaves_like 'Card Token Mocking', &block
  it_behaves_like 'Card API', &block
  it_behaves_like 'Charge API', &block
  it_behaves_like 'Coupon API', &block
  it_behaves_like 'Customer API', &block
  it_behaves_like 'Extra Features', &block
  it_behaves_like 'Invoice API', &block
  it_behaves_like 'Invoice Item API', &block
  it_behaves_like 'Plan API', &block
  it_behaves_like 'Recipient API', &block
  it_behaves_like 'Refund API', &block
  it_behaves_like 'Transfer API', &block
  it_behaves_like 'Stripe Error Mocking', &block
  it_behaves_like 'Customer Subscriptions', &block
  it_behaves_like 'Webhook Events API', &block

  # Integration tests
  it_behaves_like 'Multiple Customer Cards'
  it_behaves_like 'Charging with Tokens'
end
