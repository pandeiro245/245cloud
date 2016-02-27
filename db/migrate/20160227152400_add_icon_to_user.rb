class AddIconToUser < ActiveRecord::Migration
  def change
    add_column :users, :icon, :text
  end
end
