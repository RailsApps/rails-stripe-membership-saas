class ListingWorker
  include Sidekiq::Worker

  def perform(params)
    ap params
	  # listing = Listing.find_or_initialize_by_listing_id(:listing_id => params[:id],
   #                                                           :url => params[:url],
   #                                                           :name => params[:name],
   #                                                           :image => params[:image],
   #                                                           :desc => params[:description])
          

   #  listing.save    
  end
end