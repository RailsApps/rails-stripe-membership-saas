class RegistrationsController < Devise::RegistrationsController

  def new
    @plan = params[:plan]
    if @plan && ENV["ROLES"].include?(@plan) && @plan != "admin"
      super
    else
      redirect_to root_path, :notice => 'Please select a subscription plan below.'
    end
  end

  # below change removes ability for non-admin to make themselves admin : see below reference ## line with two ##
  # https://github.com/bastosmichael/rails-stripe-membership-saas/commit/fd6045d55113855aefc27042ed345ba9a3518839
  def update_plan
    @user = current_user
    # role = Role.find(params[:user][:role_ids]) unless params[:user][:role_ids].nil? # original code line 1
    # if @user.update_plan(role)                                                      # original code line 2
   ## comment out above TWO lines and uncomment the below FOUR lines, to protect against user making themself an admin.
    role_id = params[:user][:role_ids] unless params[:user].nil? || params[:user][:role_ids].nil?
    role = Role.find_by_id role_id unless role_id.nil?

    authorized = !role.nil? && (role.name != 'admin' || current_user.roles.first.name == 'admin')
   
    if authorized && @user.update_plan(role)
      redirect_to edit_user_registration_path, :notice => 'Updated plan.'
    else
      flash.alert = 'Unable to update plan.'
      render :edit
    end
  end

  def update_card
    @user = current_user
    @user.stripe_token = params[:user][:stripe_token] # Rails3
    if @user.save
      redirect_to edit_user_registration_path, :notice => 'Updated card.'
    else
      flash.alert = 'Unable to update card.'
      render :edit
    end
  end

  private
  def build_resource(*args)
    super
    if params[:plan]
      resource.add_role(params[:plan])
    end
  end
end