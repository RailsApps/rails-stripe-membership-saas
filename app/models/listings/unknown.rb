class Unknown < Intangible
  # An unknown listing to sell an item—for example, an listing to sell a product, the DVD of a movie, or tickets to an event.
  serialize :fields, ActiveRecord::Coders::Hstore
  # has_and_belongs_to_many :taxonomies
	
  attr_accessible :listing_id,
				  :item_id,
				  :fields

  belongs_to :item
  belongs_to :organization
end
