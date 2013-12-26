class CreateTaxonomies < ActiveRecord::Migration
  def change
    create_table :taxonomies do |t|
      t.references :parent
      t.string :name
      t.string :desc
      t.string :image
      t.string :url
      t.string :type

      t.timestamps
    end
  end
end

