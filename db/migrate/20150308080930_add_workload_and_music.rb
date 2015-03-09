class AddWorkloadAndMusic < ActiveRecord::Migration
  def change
    create_table "musics" do |t|
      t.string   "title"
      t.boolean  "is_fixed"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "total_count"
      t.text     "key"
      t.text   "user_counts"
    end

    create_table "workloads" do |t|
      t.string   "title"
      t.boolean  "is_done"
      t.string   "user_hash"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.text     "key"
      t.integer  "music_id"
      t.integer  "number"
    end
  end
end

