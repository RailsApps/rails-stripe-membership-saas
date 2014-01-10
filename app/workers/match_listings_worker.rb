class MatchListingsWorker
  @queue = :listing_queue

  def self.perform(fields)
  	@listings ||= Listing.all
    # @items = []
    fields.split(',').each do |key|
      @listings.each do |l1|
      next if l1.fields[key] == nil 
      first_listing = eval(l1.fields[key]).values.last
      @listings.each do |l2| 
        next if l2.fields[key] == nil
        next if l2.id == l1.id
        second_listing = eval(l2.fields[key]).values.last
        if first_listing == second_listing
          l1.taxonomies << l2.taxonomies
          l2.taxonomies << l1.taxonomies
            # ap "#{first_listing} == #{second_listing}"
            # item = Item.find_or_create_by_item_id(:item_id => first_listing,
            #                                       :name => l1.name,
            #                                       :url => l1.url,
            #                                       :desc => l1.desc,
            #                                       :image => l1.image)
            # item.listings << l1
            # item.listings << l2
            # item.taxonomies << l1.taxonomies
            # item.taxonomies << l2.taxonomies
            # item.save
            # @items << item
          else next end
        end
      end
    end rescue nil
  end
end