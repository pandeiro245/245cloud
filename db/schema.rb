# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2024_11_24_051318) do
  create_table "access_logs", force: :cascade do |t|
    t.string "facebook_id"
    t.text "url"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "user_id"
  end

  create_table "comments", force: :cascade do |t|
    t.string "facebook_id"
    t.integer "parent_id"
    t.text "body"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "num", default: 0
    t.integer "user_id"
  end

  create_table "instances", force: :cascade do |t|
    t.string "host"
    t.string "db_service"
    t.string "status"
    t.text "json_data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "musics", force: :cascade do |t|
    t.string "key"
    t.string "provider"
    t.string "title"
    t.string "artwork_url"
    t.string "status"
    t.integer "duration"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at", precision: nil
    t.datetime "remember_created_at", precision: nil
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at", precision: nil
    t.datetime "last_sign_in_at", precision: nil
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "facebook_id"
    t.string "discord_id"
    t.string "name"
    t.string "token"
    t.string "twitter_id"
  end

  create_table "workloads", force: :cascade do |t|
    t.string "facebook_id"
    t.string "music_key"
    t.string "title"
    t.boolean "is_done"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "number"
    t.string "artwork_url"
    t.integer "weekly_number"
    t.integer "user_id"
  end
end
