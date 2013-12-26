class CreateOrganizations < ActiveRecord::Migration
  def change
    create_table :organizations do |t|
      t.string :name
      t.string :desc
      t.string :url
      t.string :image
      t.string :type

      t.timestamps
    end
  end
end
