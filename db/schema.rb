# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20140107052418) do

  create_table "api_keys", :force => true do |t|
    t.string   "access_token"
    t.integer  "user_id"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.hstore   "fields"
  end

  add_index "api_keys", ["fields"], :name => "index_api_keys_on_fields"

  create_table "follows", :force => true do |t|
    t.integer  "followable_id",                      :null => false
    t.string   "followable_type",                    :null => false
    t.integer  "follower_id",                        :null => false
    t.string   "follower_type",                      :null => false
    t.boolean  "blocked",         :default => false, :null => false
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
  end

  add_index "follows", ["followable_id", "followable_type"], :name => "fk_followables"
  add_index "follows", ["follower_id", "follower_type"], :name => "fk_follows"

  create_table "intangibles", :force => true do |t|
    t.integer  "organization_id"
    t.string   "name"
    t.string   "desc"
    t.string   "url"
    t.string   "image"
    t.string   "type"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.hstore   "fields"
  end

  add_index "intangibles", ["fields"], :name => "index_intangibles_on_fields"

  create_table "items", :force => true do |t|
    t.string   "item_id",         :limit => 32
    t.integer  "organization_id"
    t.string   "name"
    t.string   "desc"
    t.string   "url"
    t.string   "image"
    t.string   "type"
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
    t.hstore   "fields"
  end

  add_index "items", ["fields"], :name => "index_items_on_fields"
  add_index "items", ["item_id", "url"], :name => "index_items_on_item_id_and_url", :unique => true

  create_table "items_taxonomies", :id => false, :force => true do |t|
    t.integer  "item_id",     :null => false
    t.integer  "taxonomy_id", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "items_taxonomies", ["item_id", "taxonomy_id"], :name => "index_items_taxonomies_on_item_id_and_taxonomy_id", :unique => true

  create_table "listings", :force => true do |t|
    t.string   "listing_id",      :limit => 32, :null => false
    t.integer  "organization_id"
    t.integer  "item_id"
    t.string   "name"
    t.string   "desc"
    t.string   "url"
    t.string   "image"
    t.string   "type"
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
    t.hstore   "fields"
  end

  add_index "listings", ["fields"], :name => "index_listings_on_fields"
  add_index "listings", ["listing_id", "url"], :name => "index_listings_on_listing_id_and_url", :unique => true

  create_table "listings_taxonomies", :id => false, :force => true do |t|
    t.integer  "listing_id",  :null => false
    t.integer  "taxonomy_id", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "listings_taxonomies", ["listing_id", "taxonomy_id"], :name => "index_listings_taxonomies_on_listing_id_and_taxonomy_id", :unique => true

  create_table "organization_connections", :id => false, :force => true do |t|
    t.integer  "org_a_id",   :null => false
    t.integer  "org_b_id",   :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "organization_connections", ["org_a_id", "org_b_id"], :name => "index_organization_connections_on_org_a_id_and_org_b_id", :unique => true

  create_table "organizations", :force => true do |t|
    t.string   "name"
    t.string   "desc"
    t.string   "url"
    t.string   "image"
    t.string   "type"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.hstore   "fields"
  end

  add_index "organizations", ["fields"], :name => "index_organizations_on_fields"

  create_table "pg_search_documents", :force => true do |t|
    t.text     "content"
    t.integer  "searchable_id"
    t.string   "searchable_type"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  create_table "roles", :force => true do |t|
    t.string   "name"
    t.integer  "resource_id"
    t.string   "resource_type"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "roles", ["name", "resource_type", "resource_id"], :name => "index_roles_on_name_and_resource_type_and_resource_id"
  add_index "roles", ["name"], :name => "index_roles_on_name"

  create_table "taxonomies", :force => true do |t|
    t.integer  "parent_id"
    t.string   "name"
    t.string   "desc"
    t.string   "image"
    t.string   "url"
    t.string   "type"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.hstore   "fields"
  end

  add_index "taxonomies", ["fields"], :name => "index_taxonomies_on_fields"

  create_table "unknowns", :force => true do |t|
    t.string   "listing_id",      :limit => 32, :null => false
    t.integer  "organization_id"
    t.integer  "item_id"
    t.string   "name"
    t.string   "desc"
    t.string   "url"
    t.string   "image"
    t.string   "type"
    t.hstore   "fields"
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
  end

  add_index "unknowns", ["fields"], :name => "index_unknowns_on_fields"
  add_index "unknowns", ["listing_id", "url"], :name => "index_unknowns_on_listing_id_and_url", :unique => true

  create_table "users", :force => true do |t|
    t.string   "email",                  :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
    t.string   "name"
    t.string   "customer_id"
    t.string   "last_4_digits"
    t.string   "first_name"
    t.string   "last_name"
    t.hstore   "fields"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["fields"], :name => "index_users_on_fields"
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

  create_table "users_roles", :id => false, :force => true do |t|
    t.integer "user_id"
    t.integer "role_id"
  end

  add_index "users_roles", ["user_id", "role_id"], :name => "index_users_roles_on_user_id_and_role_id"

end
