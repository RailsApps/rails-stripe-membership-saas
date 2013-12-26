class OrganizationConnection < ActiveRecord::Base
  belongs_to :org_a, :class_name => :Organization
  belongs_to :org_b, :class_name => :Organization
end