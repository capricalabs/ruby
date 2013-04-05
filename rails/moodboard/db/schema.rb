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

ActiveRecord::Schema.define(:version => 20121107095826) do

  create_table "mood_board_tiles", :force => true do |t|
    t.integer  "mood_board_id"
    t.integer  "photo_id"
    t.integer  "storage_id"
    t.integer  "x"
    t.integer  "y"
    t.integer  "width"
    t.integer  "height"
    t.integer  "edit_width"
    t.integer  "edit_height"
    t.integer  "edit_x_offset"
    t.integer  "edit_y_offset"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  create_table "mood_boards", :force => true do |t|
    t.string   "name"
    t.text     "desc"
    t.string   "status"
    t.integer  "width"
    t.integer  "height"
    t.string   "main_storage_id"
    t.string   "thumb_storage_id"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  create_table "photo_categories", :force => true do |t|
    t.string   "name"
    t.integer  "photo_category_id"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  create_table "photos", :force => true do |t|
    t.string   "name"
    t.integer  "width"
    t.integer  "height"
    t.integer  "photo_category_id"
    t.integer  "main_storage_id"
    t.integer  "thumb_storage_id"
    t.string   "anchor"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  create_table "storages", :force => true do |t|
    t.string   "randkey"
    t.string   "prefix"
    t.string   "ext"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

end
