class ItemsController < ApplicationController
  before_filter :authenticate_user!
  def index
    @items = Item.all(:include => :listings)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @items.to_json(:include => :listings) }
    end
  end
end
