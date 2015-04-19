class AddIconToMusic < ActiveRecord::Migration
  def change
    add_column :musics, :icon, :text
  end
end
