class CreateItems < ActiveRecord::Migration
  def change
    create_table :items do |t|
      t.string :item_id, :limit => 32, :primary => true
      t.belongs_to :organization
      t.string :name
      t.string :desc
      t.string :url
      t.string :image
      t.string :type

      t.timestamps
    end

  add_index :items, :item_id, :unique => true
  end
end
