class ListingsController < ApplicationController
  before_filter :authenticate_user!
  def index
  	authorize! :index, @user, :message => 'Not authorized as an administrator.'
    @listings = Listing.all(:include => :item)
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @listings.to_json(:include => :item) }
    end
  end
end
