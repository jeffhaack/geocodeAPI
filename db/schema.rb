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

ActiveRecord::Schema.define(:version => 20120615140445) do

  create_table "addresses", :force => true do |t|
    t.string   "number"
    t.integer  "street_id"
    t.float    "lon"
    t.float    "lat"
    t.integer  "settlement_id"
    t.integer  "city_district_id"
    t.integer  "official_neighborhood_id"
    t.integer  "district_id"
    t.integer  "region_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "cities", :force => true do |t|
    t.string   "name_en"
    t.string   "name_ka"
    t.float    "lat"
    t.float    "lon"
    t.integer  "district_id"
    t.integer  "region_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "city_districts", :force => true do |t|
    t.string   "name_en"
    t.string   "name_ka"
    t.float    "lat"
    t.float    "lon"
    t.integer  "settlement_id"
    t.integer  "district_id"
    t.integer  "region_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "districts", :force => true do |t|
    t.string   "name_en"
    t.string   "name_ka"
    t.float    "lat"
    t.float    "lon"
    t.integer  "region_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "official_neighborhoods", :force => true do |t|
    t.string   "name_en"
    t.string   "name_ka"
    t.float    "lat"
    t.float    "lon"
    t.integer  "city_district_id"
    t.integer  "settlement_id"
    t.integer  "district_id"
    t.integer  "region_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "regions", :force => true do |t|
    t.string   "name_en"
    t.string   "name_ka"
    t.float    "lat"
    t.float    "lon"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "searches", :force => true do |t|
    t.string   "term"
    t.string   "result"
    t.boolean  "success"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "settlements", :force => true do |t|
    t.string   "name_en"
    t.string   "name_ka"
    t.float    "lat"
    t.float    "lon"
    t.integer  "district_id"
    t.integer  "region_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "streets", :force => true do |t|
    t.string   "full_name_en"
    t.string   "full_name_ka"
    t.string   "base_name_en"
    t.string   "base_name_ka"
    t.string   "suffix_en"
    t.string   "suffix_ka"
    t.string   "street_type_en"
    t.string   "street_type_ka"
    t.float    "lat"
    t.float    "lon"
    t.string   "wkt_linestring"
    t.integer  "official_neighborhood_id"
    t.integer  "city_district_id"
    t.integer  "settlement_id"
    t.integer  "district_id"
    t.integer  "region_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "email"
    t.string   "hashed_password"
    t.string   "api_key"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
