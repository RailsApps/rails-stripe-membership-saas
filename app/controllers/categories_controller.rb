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
	  # Find the category belonging to the given id
	  @category = Category.find(params[:id])
	  # Grab all sub-categories
	  @categories = @category.subcategories
	  # We want to reuse the index renderer:
	  render :action => :index
	end

end
