class CategoriesController < ApplicationController
  before_filter :authenticate_user!
  def index
    # authorize! :index, @user, :message => 'Not authorized as an administrator.'
    @category = nil
    @categories = Category.where(:parent_id => nil).includes(:subcategories)

    respond_to do |format|
      format.html # index.html.erb
      # format.json { render json: @categories.to_json(:include => :subcategories) }
    end
  end

  def show
	  # @listings = Listing.paginate(:page => params[:page], :per_page => 12).order('updated_at DESC')
    @listings = []
    Listing.all.each do |l|
      if l.taxonomies.find_by_id(params[:id]) then @listings << l end
    end

    # Find the category belonging to the given id
	  @category = Category.find(params[:id])
	  # Grab all sub-categories
	  @categories = @category.subcategories
	  # We want to reuse the index renderer:
	  render :action => :index
	end

  def follow
    category = Category.find(params[:id])
    if current_user
      current_user.follow(category)
      flash[:notice] = "You are now following #{category.name}."
    else
      flash[:error] = "You must <a href='/users/sign_in'>login</a> to follow #{@category.name}.".html_safe
    end
    session[:return_to] ||= request.referer
    redirect_to session.delete(:return_to)
  end

  def unfollow
    @category = Category.find(params[:id])
    if current_user
      current_user.stop_following(@category)
      flash[:notice] = "You are no longer following #{@category.name}."
    else
      flash[:error] = "You must <a href='/users/sign_in'>login</a> to unfollow #{@category.html}.".html_safe
    end
    session[:return_to] ||= request.referer
    redirect_to session.delete(:return_to)
  end

end
