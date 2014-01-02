class ListingsController < ApplicationController
  before_filter :authenticate_user!
  def index
    @listings = Listing.paginate(:page => params[:page], :per_page => 12) 
    respond_to do |format|
      format.html
    end
  end
end
