class Taxonomy < Intangible
  # A Taxonomy is an intangible type of custom something, aka Tags or Categories
  has_many :subtaxonomies, :class_name => "Taxonomy", :foreign_key => "parent_id", :dependent => :destroy
  belongs_to :parent_taxonomy, :class_name => "Taxonomy"
  default_scope order('name ASC')
  acts_as_followable
end