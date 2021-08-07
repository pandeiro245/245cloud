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

ActiveRecord::Schema.define(version: 2021_08_07_022936) do

  create_table "access_logs", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.string "facebook_id"
    t.text "url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "comments", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.string "facebook_id"
    t.integer "parent_id"
    t.text "body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "num", default: 0
  end

  create_table "provider_users", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "provider_id"
    t.string "key"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["provider_id"], name: "index_provider_users_on_provider_id"
    t.index ["user_id"], name: "index_provider_users_on_user_id"
  end

  create_table "provider_workloads", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.bigint "workload_id"
    t.bigint "provider_id"
    t.bigint "provider_user_id"
    t.string "key"
    t.text "val"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["provider_id"], name: "index_provider_workloads_on_provider_id"
    t.index ["provider_user_id"], name: "index_provider_workloads_on_provider_user_id"
    t.index ["workload_id"], name: "index_provider_workloads_on_workload_id"
  end

  create_table "providers", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "facebook_id"
    t.string "discord_id"
    t.string "name"
    t.string "token"
    t.string "twitter_id"
  end

  create_table "workloads", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.string "facebook_id"
    t.string "music_key"
    t.string "title"
    t.boolean "is_done"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "number"
    t.string "artwork_url"
    t.integer "weekly_number"
    t.bigint "user_id"
    t.index ["user_id"], name: "index_workloads_on_user_id"
  end

  add_foreign_key "provider_users", "providers"
  add_foreign_key "provider_users", "users"
  add_foreign_key "provider_workloads", "provider_users"
  add_foreign_key "provider_workloads", "providers"
  add_foreign_key "provider_workloads", "workloads"
  add_foreign_key "workloads", "users"
end
