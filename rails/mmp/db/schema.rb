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

ActiveRecord::Schema.define(:version => 20120615111857) do

  create_table "addresses", :force => true do |t|
    t.integer  "user_id"
    t.boolean  "billing"
    t.boolean  "default"
    t.string   "line"
    t.string   "line2"
    t.string   "city"
    t.string   "state"
    t.string   "zip"
    t.string   "country"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "addresses", ["user_id"], :name => "index_addresses_on_user_id"

  create_table "admins", :force => true do |t|
    t.string   "email"
    t.boolean  "active",                 :default => true
    t.string   "name"
    t.datetime "created_at",                               :null => false
    t.datetime "updated_at",                               :null => false
    t.string   "encrypted_password",     :default => "",   :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.integer  "failed_attempts",        :default => 0
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.string   "phone"
  end

  add_index "admins", ["email"], :name => "index_admins_on_email", :unique => true
  add_index "admins", ["reset_password_token"], :name => "index_admins_on_reset_password_token", :unique => true
  add_index "admins", ["unlock_token"], :name => "index_admins_on_unlock_token", :unique => true

  create_table "banks", :force => true do |t|
    t.string   "city"
    t.string   "state"
    t.string   "country"
    t.text     "bank_info"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "brands", :force => true do |t|
    t.string   "name"
    t.boolean  "active",     :default => false
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
  end

  create_table "deal_quantities", :force => true do |t|
    t.integer  "deal_id"
    t.integer  "qty"
    t.decimal  "price_change", :precision => 16, :scale => 2
    t.datetime "created_at",                                  :null => false
    t.datetime "updated_at",                                  :null => false
  end

  add_index "deal_quantities", ["deal_id"], :name => "index_deal_quantities_on_deal_id"

  create_table "deals", :force => true do |t|
    t.integer  "user_id"
    t.integer  "product_id"
    t.integer  "qty"
    t.decimal  "price",                           :precision => 16, :scale => 2
    t.string   "currency",           :limit => 3
    t.date     "start_date"
    t.date     "end_date"
    t.boolean  "active",                                                         :default => true
    t.decimal  "customs_duty_price",              :precision => 16, :scale => 2
    t.decimal  "warranty_cost",                   :precision => 16, :scale => 2
    t.decimal  "addon_commission",                :precision => 5,  :scale => 2
    t.datetime "created_at",                                                                       :null => false
    t.datetime "updated_at",                                                                       :null => false
  end

  add_index "deals", ["product_id"], :name => "index_deals_on_product_id"
  add_index "deals", ["user_id"], :name => "index_deals_on_user_id"

  create_table "pages", :force => true do |t|
    t.string   "title"
    t.text     "body",       :limit => 16777215
    t.text     "meta_tags"
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
    t.string   "layout"
  end

  create_table "product_images", :force => true do |t|
    t.integer  "product_id"
    t.string   "image"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "product_images", ["product_id"], :name => "index_product_images_on_product_id"

  create_table "products", :force => true do |t|
    t.integer  "brand_id"
    t.string   "name"
    t.boolean  "active",                         :default => false
    t.string   "model"
    t.text     "summary"
    t.text     "features",   :limit => 16777215
    t.text     "warranty",   :limit => 16777215
    t.datetime "created_at",                                        :null => false
    t.datetime "updated_at",                                        :null => false
  end

  add_index "products", ["brand_id"], :name => "index_products_on_brand_id"

  create_table "users", :force => true do |t|
    t.string   "email"
    t.boolean  "dealer"
    t.string   "name"
    t.string   "company"
    t.string   "phone"
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
    t.boolean  "active",                 :default => false
    t.string   "bank_name"
    t.string   "account_name"
    t.string   "account_number"
    t.string   "swift_code"
    t.string   "encrypted_password",     :default => "",    :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.integer  "failed_attempts",        :default => 0
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.integer  "admin_id"
  end

  add_index "users", ["admin_id"], :name => "index_users_on_admin_id"
  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true
  add_index "users", ["unlock_token"], :name => "index_users_on_unlock_token", :unique => true

end
