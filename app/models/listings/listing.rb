class Listing < Intangible
  # An listing to sell an item—for example, an listing to sell a product, the DVD of a movie, or tickets to an event.
  has_and_belongs_to_many :taxonomies
	
  attr_accessible :listing_id,
				  :product_id

  belongs_to :item
  belongs_to :organization
end
