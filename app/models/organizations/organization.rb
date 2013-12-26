class Organization < Thing
  # An organization such as a school, NGO, corporation, club, etc.
  has_many :intangibles, dependent: :destroy
  has_many(:organization_connections, :foreign_key => :org_a_id, :dependent => :destroy)
  has_many(:reverse_organization_connections, :class_name => :OrganizationConnection,
      :foreign_key => :org_b_id, :dependent => :destroy)
  has_many :organizations, :through => :organization_connections, :source => :org_b
  has_many :listings, dependent: :destroy
  acts_as_followable
end
