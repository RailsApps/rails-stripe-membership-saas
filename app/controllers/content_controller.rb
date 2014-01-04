class ContentController < ApplicationController
  before_filter :authenticate_user!
  
  def silver
    authorize! :view, :silver, :message => 'Access limited to Silver Plan subscribers.'
    find_follows
  end
  
  def gold
    authorize! :view, :gold, :message => 'Access limited to Gold Plan subscribers.'
    find_follows
  end

  def platinum
    authorize! :view, :platinum, :message => 'Access limited to Platinum Plan subscribers.'
    find_follows
  end

  private

  def find_follows
    listings = []
    @listings = []
    current_user.follows.each do |f|
      if f.followable_type == "Intangible" then listings << f.followable_id end 
    end
    listings.each do |l|
      @listings << Listing.find(l)
    end
  end

end