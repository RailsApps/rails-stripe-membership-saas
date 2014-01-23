class ApplicationController < ActionController::Base
  protect_from_forgery

  # Rails4 Documentation: https://github.com/plataformatec/devise#strong-parameters
  # before_filter :update_sanitized_params, if: :devise_controller?

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_path, :alert => exception.message
  end

  def after_sign_in_path_for(resource)
    case current_user.roles.first.name
      when 'admin'
        users_path
      when 'silver'
        content_silver_path
      when 'gold'
        content_gold_path
      when 'platinum'
        content_platinum_path
      else
        root_path
    end
  end

# Rails4 Documentation: https://github.com/plataformatec/devise#strong-parameters
#  def update_sanitized_params
#    devise_parameter_sanitizer.for(:sign_up) {|u| u.permit(:name, :coupon, :stripe_token)}
#  end
end