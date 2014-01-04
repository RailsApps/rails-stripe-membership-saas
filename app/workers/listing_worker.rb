class ListingWorker
  include Sidekiq::Worker
  # sidekiq_options queue: "listing"

  def perform(params)
    listing = Listing.find_or_initialize_by_listing_id(:listing_id => params[:id],
                                                             :url => params[:url],
                                                             :image => params[:image])
          listing.name = params[:name][0..254] rescue nil
          listing.desc = params[:description][0..254] rescue nil
          # u = Unknown.find_by_listing_id(:listing_id => params[:id])
          # u.delete rescue nil

          params.delete(:id)
          params.delete(:url)
          params.delete(:name)
          params.delete(:image)
          params.delete(:description)
          
          listing.organization = Organization.find_or_create_by_name(:name => params[:site_name],
                                                                     :url => params[:site_url])
          params.delete(:site_name)
          params.delete(:site_url)

          categories = params[:categories].split(',') rescue []
          categories.each_with_index do |category, index|
            next_element = categories[index+1]
            c = Category.find_or_initialize_by_name(category)
            # if t = Tag.find_by_name(category)
            #   t.make_category
            # end
            if next_element
              c.subcategories << Category.find_or_create_by_name(next_element) rescue nil
            end
            listing.taxonomies << c rescue nil
            if index == 0 then c.parent_id = nil end
            c.save
          end
          params.delete(:categories)

          tags = params[:tags].split(',') rescue []
          tags.each do |tag|
                t = Tag.find_or_create_by_name(tag)
                listing.taxonomies << t rescue nil
          end
          params.delete(:tags)
          
          # # if params[:sameAs]
          # #   # item = Item.
          # # end
          # # params.delete(:sameAs)

          listing.fields.merge!(params)

          listing.save   
  end

  private

  def setup_db_connection dataload
    @connection = ActiveRecord::RdsDb.get_connection(dataload)
  end
end