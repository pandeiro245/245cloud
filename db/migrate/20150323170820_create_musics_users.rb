class CreateMusicsUsers < ActiveRecord::Migration
  def change
    create_table :musics_users do |t|
      t.references :music, index: true
      t.references :user, index: true
      t.integer :total, default: 0

      t.timestamps null: false
    end
    add_foreign_key :musics_users, :musics
    add_foreign_key :musics_users, :users
  end
end
