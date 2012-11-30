class RegistrationsController < Devise::RegistrationsController

  def new
    @plan = params[:plan]
    if @plan
      super
    else
      redirect_to root_path, :notice => 'Please select a subscription plan below'
    end
  end

  def update
    @user = User.find(current_user.id)
    role = Role.find(params[:user][:role_ids]) unless params[:user][:role_ids].nil?
    params[:user] = params[:user].except(:role_ids)
    successfully_updated = false
    unless params[:user][:email].nil? or params[:user][:password].nil?
      name_changed = @user.name != params[:user][:name]
      email_changed = @user.email != params[:user][:email]
      password_changed = !params[:user][:password].empty?
      if email_changed or password_changed or name_changed
        successfully_updated = @user.update_with_password(params[:user])
      end
    else
      successfully_updated = @user.update_without_password(params[:user])
    end
    if successfully_updated
      @user.update_plan(role) unless role.nil?
      set_flash_message :notice, :updated
      # Sign in the user bypassing validation in case his password changed
      sign_in @user, :bypass => true
      redirect_to after_update_path_for(@user)
    else
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
