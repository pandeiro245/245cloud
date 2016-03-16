class CreateServers < ActiveRecord::Migration
  def change
    create_table :servers do |t|
      t.string :url
      t.integer :facebook_id

      t.timestamps null: false
    end
  end
end
