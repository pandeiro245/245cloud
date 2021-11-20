class AddScreenNameToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :screen_name, :string
  end
end
