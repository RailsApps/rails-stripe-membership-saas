class CreateListingTaxonomy < ActiveRecord::Migration
  def up
  	create_table :listings_taxonomies, :id => false do |t|
      t.references :listing, :null => false
      t.references :taxonomy, :null => false

      t.timestamps :null => true
    end
    add_index :listings_taxonomies, [:listing_id, :taxonomy_id], :unique => true
  end

  def down
  end
end