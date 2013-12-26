class Category < Taxonomy
  # A category is a type of custom Taxonomy
  has_many :subcategories, :class_name => "Category", :foreign_key => "parent_id", :dependent => :destroy
  belongs_to :parent_category, :class_name => "Category"

  def make_tag
    self.type = "Tag"
    self.save!
  end
end
