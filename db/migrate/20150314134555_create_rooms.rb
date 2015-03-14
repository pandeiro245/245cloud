class CreateRooms < ActiveRecord::Migration
  def change
    create_table :rooms do |t|
      t.string :title
      t.string :image_on
      t.string :image_off
      t.integer :comments_count

      t.timestamps null: false
    end
  end
end
