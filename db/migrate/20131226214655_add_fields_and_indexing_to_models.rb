class AddFieldsAndIndexingToModels < ActiveRecord::Migration
  def change
    add_column :users, :fields, :hstore
    add_hstore_index :users, :fields

    add_column :taxonomies, :fields, :hstore
    add_hstore_index :taxonomies, :fields

    add_column :organizations, :fields, :hstore
    add_hstore_index :organizations, :fields

    add_column :items, :fields, :hstore
    add_hstore_index :items, :fields

    add_column :intangibles, :fields, :hstore
    add_hstore_index :intangibles, :fields

    add_column :listings, :fields, :hstore
    add_hstore_index :listings, :fields

    add_column :api_keys, :fields, :hstore
    add_hstore_index :api_keys, :fields
  end
end
