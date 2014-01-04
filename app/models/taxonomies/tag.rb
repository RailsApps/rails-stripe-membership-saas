class Tag < Taxonomy
  # A tag is a type of custom Taxonomy
  has_many :subtags, :class_name => "Tag", :foreign_key => "parent_id", :dependent => :destroy
  belongs_to :parent_tag, :class_name => "Tag"
  default_scope order('name ASC')
  def make_category
    self.type = "Category"
    self.save!
  end
end
