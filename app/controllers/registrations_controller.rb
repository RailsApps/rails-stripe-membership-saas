class RegistrationsController < Devise::RegistrationsController
  include Payola::StatusBehavior
  before_action :cancel_subscription, only: [:destroy]

  def new
    build_resource({})
    unless params[:plan].nil?
      @plan = Plan.find_by!(stripe_id: params[:plan])
      resource.plan = @plan
    end
    yield resource if block_given?
    respond_with self.resource
  end

  def create
    build_resource(sign_up_params)
    plan = Plan.find_by!(id: params[:user][:plan_id].to_i)
    resource.role = User.roles[plan.stripe_id] unless resource.admin?
    resource.save
    yield resource if block_given?
    if resource.persisted?
      if resource.active_for_authentication?
        set_flash_message :notice, :signed_up if is_flashing_format?
        sign_up(resource_name, resource)
        subscribe
      else
        set_flash_message :notice, :"signed_up_but_#{resource.inactive_message}" if is_flashing_format?
        expire_data_after_sign_in!
        subscribe
      end
    else
      clean_up_passwords resource
      render json:
        {error: resource.errors.full_messages.to_sentence},
        status: 400
    end
  end

  def change_plan
    plan = Plan.find_by!(id: params[:user][:plan_id].to_i)
    unless plan == current_user.plan
      role = User.roles[plan.stripe_id]
      if current_user.update_attributes!(plan: plan, role: role)
        subscription = Payola::Subscription.find_by!(owner_id: current_user.id)
        Payola::ChangeSubscriptionPlan.call(subscription, plan)
        redirect_to edit_user_registration_path, :notice => "Plan changed."
      else
        flash[:alert] = 'Unable to change plan.'
        build_resource
        render :edit
      end
    end
  end

  private

  def sign_up_params
    params.require(:user).permit(:email,
    :password, :password_confirmation, :plan_id)
  end

  def subscribe
    return if resource.admin?
    params[:plan] = current_user.plan
    subscription = Payola::CreateSubscription.call(params, current_user)
    current_user.save
    render_payola_status(subscription)
  end

  def cancel_subscription
    subscription = Payola::Subscription.find_by!(owner_id: current_user.id, state: 'active')
    Payola::CancelSubscription.call(subscription)
  end

end
