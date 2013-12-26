class TagsController < ApplicationController
  before_filter :authenticate_user!
  def index
    @tags = Tag.all
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @tags.to_json }
    end
  end
end
