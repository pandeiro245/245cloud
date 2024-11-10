class CreateMusics < ActiveRecord::Migration[6.1]
  def change
    create_table :musics do |t|
      t.string :key
      t.string :provider
      t.string :title
      t.string :artwork_url
      t.string :status
      t.integer :duration

      t.timestamps
    end
  end
end
