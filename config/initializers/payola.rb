Payola.configure do |config|
  config.secret_key = Rails.application.secrets.stripe_api_key
  config.publishable_key = Rails.application.secrets.stripe_publishable_key
  Payola.subscribe 'customer.subscription.deleted' do |event|
    sale = Sale.find_by(stripe_id: event.data.object.id)
    user = User.find_by(email: sale.email)
    UserMailer.expire_email(user).deliver
    user.destroy
  end
end
