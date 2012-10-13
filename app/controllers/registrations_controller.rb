class RegistrationsController < Devise::RegistrationsController

  def new
    @plan = params[:plan]
    super
  end

  private
  def build_resource(*args)
    super
    if params[:plan]
      resource.add_role(params[:plan])
    end
  end
end