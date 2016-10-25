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

ActiveRecord::Schema.define(version: 20160611175825) do

  create_table "access_logs", force: :cascade do |t|
    t.string   "facebook_id", limit: 255
    t.text     "url",         limit: 65535
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  create_table "comments", force: :cascade do |t|
    t.string   "facebook_id", limit: 255
    t.integer  "parent_id",   limit: 4
    t.text     "body",        limit: 65535
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.integer  "num",         limit: 4,     default: 0
  end

  create_table "issue_workloads", force: :cascade do |t|
    t.integer  "issue_id",    limit: 4
    t.integer  "workload_id", limit: 4
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  add_index "issue_workloads", ["issue_id"], name: "index_issue_workloads_on_issue_id", using: :btree
  add_index "issue_workloads", ["workload_id"], name: "index_issue_workloads_on_workload_id", using: :btree

  create_table "issues", force: :cascade do |t|
    t.integer  "user_id",    limit: 4
    t.string   "key",        limit: 255
    t.integer  "estimated",  limit: 4
    t.integer  "worked",     limit: 4
    t.datetime "deadline"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "issues", ["user_id"], name: "index_issues_on_user_id", using: :btree

  create_table "musics", force: :cascade do |t|
    t.string   "title",       limit: 255
    t.string   "key",         limit: 255
    t.boolean  "active",      limit: 1
    t.string   "artwork_url", limit: 255
    t.text     "icon",        limit: 65535
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  limit: 255,   default: "", null: false
    t.string   "encrypted_password",     limit: 255,   default: "", null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          limit: 4,     default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.datetime "created_at",                                        null: false
    t.datetime "updated_at",                                        null: false
    t.string   "facebook_id",            limit: 255
    t.text     "icon",                   limit: 65535
  end

  create_table "workloads", force: :cascade do |t|
    t.string   "facebook_id",   limit: 255
    t.string   "music_key",     limit: 255
    t.string   "title",         limit: 255
    t.boolean  "is_done",       limit: 1
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.integer  "number",        limit: 4
    t.string   "artwork_url",   limit: 255
    t.integer  "weekly_number", limit: 4
  end

  add_foreign_key "issue_workloads", "issues"
  add_foreign_key "issue_workloads", "workloads"
  add_foreign_key "issues", "users"
end
