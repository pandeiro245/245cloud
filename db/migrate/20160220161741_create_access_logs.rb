class CreateAccessLogs < ActiveRecord::Migration
  def change
    create_table :access_logs do |t|
      t.integer :facebook_id
      t.text :url

      t.timestamps null: false
    end
  end
end
