class CreateItemTaxonomy < ActiveRecord::Migration
  def up
  	create_table :items_taxonomies, :id => false do |t|
      t.references :item, :null => false
      t.references :taxonomy, :null => false

      t.timestamps :null => true
    end
    add_index :items_taxonomies, [:item_id, :taxonomy_id], :unique => true
  end

  def down
  end
end