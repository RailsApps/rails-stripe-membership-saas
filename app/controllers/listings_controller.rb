class ListingsController < ApplicationController
  before_filter :authenticate_user!
  def index
    @listings ||= Listing.paginate(:page => params[:page], :per_page => 12).order('updated_at DESC')
    respond_to do |format|
      format.html
    end
  end

  def show
    @listing ||= Listing.find(params[:id])
    @fields ||= parse_latest_fields @listing.fields
    respond_to do |format|
      format.html
    end
  end

  def follow
  	listing = Listing.find(params[:id])
  	if current_user
  	  current_user.follow(listing)
  	  flash[:notice] = "You are now following #{listing.name}."
  	else
  	  flash[:error] = "You must <a href='/users/sign_in'>login</a> to follow #{@listing.name}.".html_safe
  	end
	  session[:return_to] ||= request.referer
	  redirect_to session.delete(:return_to)
  end

  def unfollow
    @listing = Listing.find(params[:id])
    if current_user
      current_user.stop_following(@listing)
  	  flash[:notice] = "You are no longer following #{@listing.name}."
  	else
  	  flash[:error] = "You must <a href='/users/sign_in'>login</a> to unfollow #{@listing.html}.".html_safe
  	end
  	session[:return_to] ||= request.referer
  	redirect_to session.delete(:return_to)
  end

  private

  def parse_latest_fields fields={}
    fields.each do |key, value|
      value = eval(value)
      fields[key] = value.values.last
    end
    return fields
  end
end
