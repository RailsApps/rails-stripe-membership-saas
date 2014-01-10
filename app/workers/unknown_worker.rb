class UnknownWorker
  @queue = :listing_queue

  def perform(params)
    unknown = Unknown.find_or_initialize_by_listing_id(:listing_id => params[:id],
                                                             :url => params[:url],
                                                             :image => params[:image])
          unknown.name = params[:name][0..254] rescue nil
          unkonwn.desc = params[:description][0..254] rescue nil
          params.delete(:id)
          params.delete(:url)
          params.delete(:name)
          params.delete(:image)
          params.delete(:description)
          
          listing.organization = Organization.find_or_create_by_name(:name => params[:site_name],
                                                                     :url => params[:site_url])
          params.delete(:site_name)
          params.delete(:site_url)

          unknown.fields.merge!(params)

          unknown.save
  end
end