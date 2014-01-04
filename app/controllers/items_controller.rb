class ItemsController < ApplicationController
  before_filter :authenticate_user!
  def index
    @items ||= Item.paginate(:page => params[:page], :per_page => 12).order('updated_at DESC')

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @items.to_json(:include => :listings) }
    end
  end

  def follow
  	item = Item.find(params[:id])
	if current_user
	  current_user.follow(item)
	  flash[:notice] = "You are now following #{item.name}."
	else
	  flash[:error] = "You must <a href='/users/sign_in'>login</a> to follow #{@item.name}.".html_safe
	end
	  session[:return_to] ||= request.referer
	  redirect_to session.delete(:return_to)
  end

  def unfollow
    @item = Item.find(params[:id])
    if current_user
      current_user.stop_following(@item)
	  flash[:notice] = "You are no longer following #{@item.name}."
	else
	  flash[:error] = "You must <a href='/users/sign_in'>login</a> to unfollow #{@item.html}.".html_safe
	end
	session[:return_to] ||= request.referer
	redirect_to session.delete(:return_to)
  end
end
