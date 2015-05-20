class ContentController < ApplicationController
  before_action :authenticate_user!

  def silver
    redirect_to content_silver_path, :notice => "Access denied." unless (current_user.plan.id == 1) || current_user.admin?
  end

  def gold
    redirect_to content_gold_path, :notice => "Access denied." unless (current_user.plan.id == 2) || current_user.admin?
  end

  def platinum
    redirect_to content_platinum_path, :notice => "Access denied." unless (current_user.plan.id == 3) || current_user.admin?
  end

end
