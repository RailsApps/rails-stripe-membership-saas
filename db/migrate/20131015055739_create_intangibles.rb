class CreateIntangibles < ActiveRecord::Migration
  def change
    create_table :intangibles do |t|
      t.belongs_to :organization
      t.string :name
      t.string :desc
      t.string :url
      t.string :image
      t.string :type

      t.timestamps
    end
  end
end
