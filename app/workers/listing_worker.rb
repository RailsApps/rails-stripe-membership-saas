class ListingWorker
  include Sidekiq::Worker

  def perform(params)
    ap params
	listing = Listing.find_or_initialize_by_listing_id(:listing_id => params[:id],
                                                             :url => params[:url],
                                                             :name => params[:name],
                                                             :image => params[:image],
                                                             :desc => params[:description])
          params.delete(:id)
          params.delete(:url)
          params.delete(:name)
          params.delete(:image)
          params.delete(:description)
          
          # listing.organization = Organization.find_by_name(params[:site_name])
          # params.delete(:site_name)
          
          # categories = params[:categories].split(',')
          # categories.each_with_index do |category, index|
          #   ap index
          #   c = Category.find_or_initialize_by_name(category)
          #   c.subcategories << Category.find_or_create_by_name(categories[index+1]) rescue nil
          #   listing.taxonomies << c rescue nil
          #   c.save
          # end
          # params.delete(:categories)

          # tags = params[:tags].split(',')
          # tags.each do |tag|
          #   t = Tag.find_or_initialize_by_name(tag)
          #   listing.taxonomies << t rescue nil
          #   t.save
          # end
          # params.delete(:tags)
          
          # listing.fields.merge!(params)

          listing.save    
  end
end