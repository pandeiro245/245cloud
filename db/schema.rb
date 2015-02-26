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
# It's strongly recommended that you check this file into your version control system.

<<<<<<< HEAD
ActiveRecord::Schema.define(version: 0) do
=======
ActiveRecord::Schema.define(version: 20150226122652) do

  create_table "musics", force: :cascade do |t|
    t.string   "title",       limit: 255
    t.boolean  "is_fixed",    limit: 1
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "total_count", limit: 4
    t.text     "key",         limit: 65535
    t.text     "user_counts", limit: 65535
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  limit: 255, default: "", null: false
    t.string   "encrypted_password",     limit: 255, default: "", null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          limit: 4,   default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "workloads", force: :cascade do |t|
    t.string   "title",      limit: 255
    t.boolean  "is_done",    limit: 1
    t.string   "user_hash",  limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "key",        limit: 65535
    t.integer  "music_id",   limit: 4
  end
>>>>>>> [WIP] add Workload, User, Music

end
