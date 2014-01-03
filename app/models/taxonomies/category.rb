class Category < Taxonomy
  # A category is a type of custom Taxonomy
  has_many :subcategories, :class_name => "Category", :foreign_key => "parent_id", :dependent => :destroy
  belongs_to :parent_category, :class_name => "Category"
  has_and_belongs_to_many :items
  has_and_belongs_to_many :listings
  validates_uniqueness_of :name
  acts_as_followable
  def make_tag
    self.type = "Tag"
    self.save!
  end
end
