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
    role = Role.find(params[:user][:role_ids]) unless params[:user][:role_ids].nil?
    params[:user] = params[:user].except(:role_ids)
    super
    resource.update_plan(role) unless role.nil?
  end
  
  private
  def build_resource(*args)
    super
    if params[:plan]
      resource.add_role(params[:plan])
    end
  end
end
