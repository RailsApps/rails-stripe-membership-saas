class ContentController < ApplicationController
  before_filter :authenticate_user!
  
  def silver
    authorize! :view, :silver, :message => 'Access limited to Silver Plan subscribers.'
    # CanCan method to be replaced by Pundit
  end
  
  def gold
    authorize! :view, :gold, :message => 'Access limited to Gold Plan subscribers.'
    # CanCan method to be replaced by Pundit
  end

  def platinum
    authorize! :view, :platinum, :message => 'Access limited to Platinum Plan subscribers.'
    # CanCan method to be replaced by Pundit
  end
end