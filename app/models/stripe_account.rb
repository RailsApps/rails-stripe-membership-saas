class StripeAccount < Struct.new(:user)

  def self.create(user)
    new(user).create_customer
  end

  def self.update(user)
    new(user).update_customer
  end

  def self.cancel(user)
    new(user).cancel_customer
    user.delete
  end

  def cancel_customer
    if customer = retrieve_customer
      unless customer.respond_to?('deleted')
        customer.cancel_subscription if customer.subscription.status == 'active'
      end
    end
  end

  def retrieve_customer
    Stripe::Customer.retrieve(user.customer_id) if user.customer_id
  end

  def update_customer
    customer = retrieve_customer
    if user.stripe_token.present?
      customer.card = user.stripe_token
    end
    customer.email = user.email
    customer.description = user.name
    customer.save
    store_user_stripe_info(customer)
  end

  def store_user_stripe_info(customer)
    user.last_4_digits = customer.active_card.last4
    user.customer_id = customer.id
    user.stripe_token = nil
  end

  def create_customer
    raise "Stripe token not present. Can't create account." if user.stripe_token.blank?
    user.coupon.blank? ? create_customer_without_coupon : create_customer_with_coupon
  end

  def create_customer_without_coupon
    customer = Stripe::Customer.create(stripe_params)
    store_user_stripe_info(customer)
  end

  def create_customer_with_coupon
    customer = Stripe::Customer.create(
      stripe_params.merge(coupon: user.coupon)
    )
    store_user_stripe_info(customer)
  end

  def stripe_params
    {
      email: user.email,
      description: user.name,
      card: user.stripe_token,
      plan: user.roles.first.name
    }
  end

end
