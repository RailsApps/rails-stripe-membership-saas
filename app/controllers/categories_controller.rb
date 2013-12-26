class CategoriesController < ApplicationController
  before_filter :authenticate_user!
  def index
    # authorize! :index, @user, :message => 'Not authorized as an administrator.'
    @categories = Category.where(:parent_id => nil).includes(:subcategories)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @categories.to_json(:include => :subcategories) }
    end
  end
end
