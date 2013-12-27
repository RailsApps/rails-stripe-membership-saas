class CreateUnknowns < ActiveRecord::Migration
  def change
    create_table :unknowns do |t|
      t.string :listing_id, :limit => 32, :null => false, :primary => true
      t.belongs_to :organization
      t.belongs_to :item
      t.string :name
      t.string :desc
      t.string :url
      t.string :image
      t.string :type
      t.hstore :fields

      t.timestamps
    end

  add_index 'unknowns', ["listing_id", "url"], :unique => true
  add_hstore_index :unknowns, :fields
  end
end
