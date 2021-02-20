# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_02_18_104249) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "fares", force: :cascade do |t|
    t.time "duration"
    t.integer "fee"
    t.bigint "result_station_id", null: false
    t.bigint "station_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["result_station_id"], name: "index_fares_on_result_station_id"
    t.index ["station_id"], name: "index_fares_on_station_id"
  end

  create_table "locations", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "meetle_id", null: false
    t.bigint "station_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["meetle_id"], name: "index_locations_on_meetle_id"
    t.index ["station_id"], name: "index_locations_on_station_id"
    t.index ["user_id"], name: "index_locations_on_user_id"
  end

  create_table "meetles", force: :cascade do |t|
    t.date "date_time"
    t.string "activity"
    t.boolean "active"
    t.bigint "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_meetles_on_user_id"
  end

  create_table "result_stations", force: :cascade do |t|
    t.bigint "station_id", null: false
    t.bigint "meetle_id", null: false
    t.integer "vote"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["meetle_id"], name: "index_result_stations_on_meetle_id"
    t.index ["station_id"], name: "index_result_stations_on_station_id"
  end

  create_table "stations", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "name_kanji"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "username"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "fares", "result_stations"
  add_foreign_key "fares", "stations"
  add_foreign_key "locations", "meetles"
  add_foreign_key "locations", "stations"
  add_foreign_key "locations", "users"
  add_foreign_key "meetles", "users"
  add_foreign_key "result_stations", "meetles"
  add_foreign_key "result_stations", "stations"
end
