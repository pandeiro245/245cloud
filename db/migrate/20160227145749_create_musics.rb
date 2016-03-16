class CreateMusics < ActiveRecord::Migration
  def change
    create_table :musics do |t|
      t.string :title
      t.string :key
      t.boolean :active
      t.string :artwork_url
      t.text :icon

      t.timestamps null: false
    end
  end
end
