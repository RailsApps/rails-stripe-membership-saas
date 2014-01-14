class ListingWorker
  @queue = :listing_queue

  def self.perform(params)
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
          
          params.each do |key, value|
            if value.blank? then params.delete(key) end
          end
          # changes = []
          params.each do |key, value|
            if listing.fields[key]
              original_hash = eval(listing.fields[key])
              
              new_hash = {}
              
              last_key = original_hash.keys.last
              
              original_hash.each do |k, v|
              
                if k == last_key && v != value
                  new_hash["#{Time.now.utc}"] = value
                  # changes << key
                end
              
              end
              
              listing.fields[key] = original_hash.merge!(new_hash)
            else
              listing.fields[key] = {"#{Time.now.utc}" => value}
            end
          end
          # ap changes
          # listing.fields[:last_changed] = changes
          listing.save   
  end
end