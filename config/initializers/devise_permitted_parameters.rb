module DevisePermittedParameters
  extend ActiveSupport::Concern

  included do
    before_action :configure_permitted_parameters
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_in)        { |u| u.permit(:email, :password, :remember_me) }
    devise_parameter_sanitizer.for(:account_update) { |u| u.permit(:email, :password, :password_confirmation, :current_password) }
    devise_parameter_sanitizer.for(:sign_up)        { |u| u.permit(:name, :coupon, :stripe_token, :email, :password, :password_confirmation) }
  end
end

DeviseController.send :include, DevisePermittedParameters