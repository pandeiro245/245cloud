class CreateAuths < ActiveRecord::Migration
  def change
    create_table :auths do |t|
      t.integer :user_id
      t.string :provider
      t.string :id
      t.string :name
      t.string :nickname
      t.string :image
      t.text :raw
      t.string :token
      t.string :text
      t.text :credentials

      t.timestamps null: false
    end
  end
end
