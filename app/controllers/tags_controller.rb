class TagsController < ApplicationController
  before_filter :authenticate_user!
  def index
  	authorize! :index, @user, :message => 'Not authorized as an administrator.'
    @tags ||= Tag.all
    respond_to do |format|
      format.html
    end
  end
end
