class Intangible < Thing
  belongs_to :organization
  has_many :items, dependent: :destroy
  # A utility class that serves as the umbrella for a number of 'intangible' things such as quantities, structured values, etc.
  self.abstract_class = true
end