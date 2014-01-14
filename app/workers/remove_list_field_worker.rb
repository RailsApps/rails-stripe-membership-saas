class RemoveListFieldWorker
  @queue = :listing_queue

  def self.perform(fields)
  	listings ||= Listing.all
    fields.split(',').each do |key|
      listings.each do |l|
        l.fields.delete(key)
        l.save
      end
    end rescue nil
  end
end