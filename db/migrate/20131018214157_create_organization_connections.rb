class CreateOrganizationConnections < ActiveRecord::Migration
  def up
  	create_table :organization_connections, :id => false do |t|
      t.references :org_a, :null => false
      t.references :org_b, :null => false

      t.timestamps :null => true
    end
    add_index :organization_connections, [:org_a_id, :org_b_id], :unique => true
  end

  def down
  end
end
