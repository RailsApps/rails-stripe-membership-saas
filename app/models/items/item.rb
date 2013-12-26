class Item < Thing
  belongs_to :organization
  belongs_to :intangible
  has_and_belongs_to_many :taxonomies
  has_many :listings, dependent: :destroy
  acts_as_followable
end
