class CreateListings < ActiveRecord::Migration
  def change
    create_table :listings do |t|
      t.string :listing_id, :limit => 32, :null => false, :primary => true
      t.belongs_to :organization
      t.belongs_to :item
      t.string :name
      t.string :desc
      t.string :url
      t.string :image
      t.string :type

      t.timestamps
    end

  add_index :listings, :listing_id, :unique => true
  end
end
