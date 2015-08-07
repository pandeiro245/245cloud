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

ActiveRecord::Schema.define(version: 20150807151637) do

  create_table "auths", force: :cascade do |t|
    t.integer  "user_id",     limit: 4
    t.string   "provider",    limit: 191
    t.string   "uid",         limit: 191
    t.string   "name",        limit: 191
    t.string   "nickname",    limit: 191
    t.string   "image",       limit: 191
    t.text     "raw",         limit: 65535
    t.string   "token",       limit: 191
    t.string   "text",        limit: 191
    t.text     "credentials", limit: 65535
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  create_table "cities", force: :cascade do |t|
    t.string   "name",       limit: 191
    t.integer  "pref_id",    limit: 4
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.text     "info",       limit: 65535
  end

  add_index "cities", ["pref_id"], name: "index_cities_on_pref_id", using: :btree

  create_table "comfy_cms_blocks", force: :cascade do |t|
    t.string   "identifier",     limit: 191,      null: false
    t.text     "content",        limit: 16777215
    t.integer  "blockable_id",   limit: 4
    t.string   "blockable_type", limit: 191
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "comfy_cms_blocks", ["blockable_id", "blockable_type"], name: "index_comfy_cms_blocks_on_blockable_id_and_blockable_type", using: :btree
  add_index "comfy_cms_blocks", ["identifier"], name: "index_comfy_cms_blocks_on_identifier", using: :btree

  create_table "comfy_cms_categories", force: :cascade do |t|
    t.integer "site_id",          limit: 4,   null: false
    t.string  "label",            limit: 191, null: false
    t.string  "categorized_type", limit: 191, null: false
  end

  add_index "comfy_cms_categories", ["site_id", "categorized_type", "label"], name: "index_cms_categories_on_site_id_and_cat_type_and_label", unique: true, using: :btree

  create_table "comfy_cms_categorizations", force: :cascade do |t|
    t.integer "category_id",      limit: 4,   null: false
    t.string  "categorized_type", limit: 191, null: false
    t.integer "categorized_id",   limit: 4,   null: false
  end

  add_index "comfy_cms_categorizations", ["category_id", "categorized_type", "categorized_id"], name: "index_cms_categorizations_on_cat_id_and_catd_type_and_catd_id", unique: true, using: :btree

  create_table "comfy_cms_files", force: :cascade do |t|
    t.integer  "site_id",           limit: 4,                null: false
    t.integer  "block_id",          limit: 4
    t.string   "label",             limit: 191,              null: false
    t.string   "file_file_name",    limit: 191,              null: false
    t.string   "file_content_type", limit: 191,              null: false
    t.integer  "file_file_size",    limit: 4,                null: false
    t.string   "description",       limit: 2048
    t.integer  "position",          limit: 4,    default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "comfy_cms_files", ["site_id", "block_id"], name: "index_comfy_cms_files_on_site_id_and_block_id", using: :btree
  add_index "comfy_cms_files", ["site_id", "file_file_name"], name: "index_comfy_cms_files_on_site_id_and_file_file_name", using: :btree
  add_index "comfy_cms_files", ["site_id", "label"], name: "index_comfy_cms_files_on_site_id_and_label", using: :btree
  add_index "comfy_cms_files", ["site_id", "position"], name: "index_comfy_cms_files_on_site_id_and_position", using: :btree

  create_table "comfy_cms_layouts", force: :cascade do |t|
    t.integer  "site_id",    limit: 4,                        null: false
    t.integer  "parent_id",  limit: 4
    t.string   "app_layout", limit: 191
    t.string   "label",      limit: 191,                      null: false
    t.string   "identifier", limit: 191,                      null: false
    t.text     "content",    limit: 16777215
    t.text     "css",        limit: 16777215
    t.text     "js",         limit: 16777215
    t.integer  "position",   limit: 4,        default: 0,     null: false
    t.boolean  "is_shared",  limit: 1,        default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "comfy_cms_layouts", ["parent_id", "position"], name: "index_comfy_cms_layouts_on_parent_id_and_position", using: :btree
  add_index "comfy_cms_layouts", ["site_id", "identifier"], name: "index_comfy_cms_layouts_on_site_id_and_identifier", unique: true, using: :btree

  create_table "comfy_cms_pages", force: :cascade do |t|
    t.integer  "site_id",        limit: 4,                        null: false
    t.integer  "layout_id",      limit: 4
    t.integer  "parent_id",      limit: 4
    t.integer  "target_page_id", limit: 4
    t.string   "label",          limit: 191,                      null: false
    t.string   "slug",           limit: 191
    t.string   "full_path",      limit: 191,                      null: false
    t.text     "content_cache",  limit: 16777215
    t.integer  "position",       limit: 4,        default: 0,     null: false
    t.integer  "children_count", limit: 4,        default: 0,     null: false
    t.boolean  "is_published",   limit: 1,        default: true,  null: false
    t.boolean  "is_shared",      limit: 1,        default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "comfy_cms_pages", ["parent_id", "position"], name: "index_comfy_cms_pages_on_parent_id_and_position", using: :btree
  add_index "comfy_cms_pages", ["site_id", "full_path"], name: "index_comfy_cms_pages_on_site_id_and_full_path", using: :btree

  create_table "comfy_cms_revisions", force: :cascade do |t|
    t.string   "record_type", limit: 191,      null: false
    t.integer  "record_id",   limit: 4,        null: false
    t.text     "data",        limit: 16777215
    t.datetime "created_at"
  end

  add_index "comfy_cms_revisions", ["record_type", "record_id", "created_at"], name: "index_cms_revisions_on_rtype_and_rid_and_created_at", using: :btree

  create_table "comfy_cms_sites", force: :cascade do |t|
    t.string  "label",       limit: 191,                 null: false
    t.string  "identifier",  limit: 191,                 null: false
    t.string  "hostname",    limit: 191,                 null: false
    t.string  "path",        limit: 191
    t.string  "locale",      limit: 191, default: "en",  null: false
    t.boolean "is_mirrored", limit: 1,   default: false, null: false
  end

  add_index "comfy_cms_sites", ["hostname"], name: "index_comfy_cms_sites_on_hostname", using: :btree
  add_index "comfy_cms_sites", ["is_mirrored"], name: "index_comfy_cms_sites_on_is_mirrored", using: :btree

  create_table "comfy_cms_snippets", force: :cascade do |t|
    t.integer  "site_id",    limit: 4,                        null: false
    t.string   "label",      limit: 191,                      null: false
    t.string   "identifier", limit: 191,                      null: false
    t.text     "content",    limit: 16777215
    t.integer  "position",   limit: 4,        default: 0,     null: false
    t.boolean  "is_shared",  limit: 1,        default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "comfy_cms_snippets", ["site_id", "identifier"], name: "index_comfy_cms_snippets_on_site_id_and_identifier", unique: true, using: :btree
  add_index "comfy_cms_snippets", ["site_id", "position"], name: "index_comfy_cms_snippets_on_site_id_and_position", using: :btree

  create_table "comments", force: :cascade do |t|
    t.integer  "user_id",      limit: 4
    t.text     "content",      limit: 65535
    t.integer  "room_id",      limit: 4
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.string   "parsehash",    limit: 191
    t.string   "parsecomhash", limit: 191
  end

  create_table "musics", force: :cascade do |t|
    t.string   "title",       limit: 191
    t.boolean  "is_fixed",    limit: 1
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "total_count", limit: 4
    t.text     "key",         limit: 65535
    t.text     "user_counts", limit: 65535
    t.text     "icon",        limit: 65535
  end

  create_table "musics_users", force: :cascade do |t|
    t.integer  "music_id",   limit: 4
    t.integer  "user_id",    limit: 4
    t.integer  "total",      limit: 4, default: 0
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
  end

  add_index "musics_users", ["music_id"], name: "index_musics_users_on_music_id", using: :btree
  add_index "musics_users", ["user_id"], name: "index_musics_users_on_user_id", using: :btree

  create_table "places", force: :cascade do |t|
    t.string   "name",       limit: 191
    t.integer  "pref_id",    limit: 4
    t.integer  "city_id",    limit: 4
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.text     "info",       limit: 65535
  end

  add_index "places", ["city_id"], name: "index_places_on_city_id", using: :btree
  add_index "places", ["pref_id"], name: "index_places_on_pref_id", using: :btree

  create_table "postals", force: :cascade do |t|
    t.string   "code",       limit: 191
    t.integer  "pref_id",    limit: 4
    t.integer  "city_id",    limit: 4
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.string   "lot",        limit: 191
    t.integer  "flag1",      limit: 4
    t.integer  "flag2",      limit: 4
    t.integer  "flag3",      limit: 4
    t.integer  "flag4",      limit: 4
    t.integer  "flag5",      limit: 4
    t.integer  "flag6",      limit: 4
    t.text     "info",       limit: 65535
  end

  add_index "postals", ["city_id"], name: "index_postals_on_city_id", using: :btree
  add_index "postals", ["pref_id"], name: "index_postals_on_pref_id", using: :btree

  create_table "prefs", force: :cascade do |t|
    t.string   "name",       limit: 191
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.text     "info",       limit: 65535
  end

  create_table "rooms", force: :cascade do |t|
    t.string   "title",          limit: 191
    t.string   "image_on",       limit: 191
    t.string   "image_off",      limit: 191
    t.integer  "comments_count", limit: 4
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  limit: 191, default: "", null: false
    t.string   "encrypted_password",     limit: 191, default: "", null: false
    t.string   "reset_password_token",   limit: 191
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          limit: 4,   default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 191
    t.string   "last_sign_in_ip",        limit: 191
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name",                   limit: 191
    t.string   "parsecomhash",           limit: 191
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "workloads", force: :cascade do |t|
    t.string   "title",        limit: 191
    t.integer  "status",       limit: 1,     default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "key",          limit: 65535
    t.integer  "music_id",     limit: 4
    t.integer  "number",       limit: 4
    t.integer  "user_id",      limit: 4
    t.string   "parsehash",    limit: 191
    t.string   "parsecomhash", limit: 191
    t.integer  "place_id",     limit: 4
  end

  add_index "workloads", ["place_id"], name: "index_workloads_on_place_id", using: :btree

  add_foreign_key "musics_users", "musics"
  add_foreign_key "musics_users", "users"
  add_foreign_key "places", "cities"
  add_foreign_key "places", "prefs"
  add_foreign_key "workloads", "places"
end
