class SetupSchema < ActiveRecord::Migration
  def change
    create_table :addresses do |t|
      t.string   :number
      t.integer  :street_id
      t.float    :lon
      t.float    :lat
      t.integer  :settlement_id
      t.integer  :city_district_id
      t.integer  :official_neighborhood_id
      t.integer  :district_id
      t.integer  :region_id
      t.timestamps
    end

    create_table :cities do |t|
      t.string   :name_en
      t.string   :name_ka
      t.float    :lat
      t.float    :lon
      t.integer  :district_id
      t.integer  :region_id
      t.timestamps
    end

    create_table :city_districts do |t|
      t.string   :name_en
      t.string   :name_ka
      t.float    :lat
      t.float    :lon
      t.integer  :settlement_id
      t.integer  :district_id
      t.integer  :region_id
      t.timestamps
    end

    create_table :districts do |t|
      t.string   :name_en
      t.string   :name_ka
      t.float    :lat
      t.float    :lon
      t.integer  :region_id
      t.timestamps
    end

    create_table :official_neighborhoods do |t|
      t.string   :name_en
      t.string   :name_ka
      t.float    :lat
      t.float    :lon
      t.integer  :city_district_id
      t.integer  :settlement_id
      t.integer  :district_id
      t.integer  :region_id
      t.timestamps
    end

    create_table :regions do |t|
      t.string   :name_en
      t.string   :name_ka
      t.float    :lat
      t.float    :lon
      t.timestamps
    end

    create_table :searches do |t|
      t.string   :term
      t.string   :result
      t.boolean  :success
      t.timestamps
    end

    create_table :sessions do |t|
      t.string   :session_id, :null => false
      t.text     :data
      t.timestamps
    end

    add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
    add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

    create_table :settlements do |t|
      t.string   :name_en
      t.string   :name_ka
      t.float    :lat
      t.float    :lon
      t.integer  :district_id
      t.integer  :region_id
      t.timestamps
    end

    create_table :streets do |t|
      t.string   :full_name_en
      t.string   :full_name_ka
      t.string   :base_name_en
      t.string   :base_name_ka
      t.string   :suffix_en
      t.string   :suffix_ka
      t.string   :street_type_en
      t.string   :street_type_ka
      t.float    :lat
      t.float    :lon
      t.string   :wkt_linestring
      t.integer  :official_neighborhood_id
      t.integer  :city_district_id
      t.integer  :settlement_id
      t.integer  :district_id
      t.integer  :region_id
      t.timestamps
    end

    create_table :users do |t|
      t.string   :email
      t.string   :hashed_password
      t.string   :api_key
      t.timestamps
    end

  end

end
