class TaxonomiesController < ApplicationController
  before_filter :authenticate_user!
  def index
  	authorize! :index, @user, :message => 'Not authorized as an administrator.'
    @taxonomies ||= Taxonomy.all
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @taxonomies.to_json }
    end
  end
end
