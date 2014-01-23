class UsersController < ApplicationController
  before_filter :authenticate_user!

  def index
    authorize! :index, @user, :message => 'Not authorized as an administrator.'
    @users = User.all
  end

  def show
    @user = User.find(params[:id]) # Rails3
   #@user = User.find(id_params)   # Rails4 : see private def id_params below
   #Rails4 reference for this change : http://edgeapi.rubyonrails.org/classes/ActionController/StrongParameters.html
  end
  
  def update
    authorize! :update, @user, :message => 'Not authorized as an administrator.'
    @user = User.find(params[:id])              # Rails3
   #@user = User.find(id_params)                # Rails4
    role = Role.find(params[:user][:role_ids]) unless params[:user][:role_ids].nil?              # Rails3
   #role = Role.find(params(:user).permit(:role_ids) unless params(:user).permit(:role_ids).nil? # Rails4 ? correct ?
    params[:user] = params[:user].except(:role_ids)                                   # Rails3
   #params.require(:user) = params.require(:user).permit(:id, :name, :email)          # Rails4 ? how to verify correct
    if @user.update_attributes(params[:user])                                         # Rails3 \/ both appear to work
   #if @user.update_attributes(user_params)                                           # Rails4 /\ how to verify working ?
      @user.update_plan(role) unless role.nil?
      redirect_to users_path, :notice => "User updated."
    else
      redirect_to users_path, :alert => "Unable to update user."
    end
  end
    
  def destroy
    authorize! :destroy, @user, :message => 'Not authorized as an administrator.'
    user = User.find(params[:id])  # Rails3
   #user = User.find(id_params)    # Rails4 ? how to verify this is working code ?
    unless user == current_user
      user.destroy
      redirect_to users_path, :notice => "User deleted."
    else
      redirect_to users_path, :notice => "Can't delete yourself."
    end
  end

#  private                                                                        # Rails4
#    def id_params                                                                # Rails4
#        params.require(:user).permit(:name, :coupon, :stripe_token) # Rails4
#    end                                                                          # Rails4

#    def user_params                                                              # Rails4
#        params.require(:user).permit(:name, :coupon, :role_ids, :stripe_token)   # Rails4
#    end                                                                          # Rails4
end
