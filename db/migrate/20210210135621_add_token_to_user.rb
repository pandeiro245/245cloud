class AddTokenToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :name, :string, unique: true
    add_column :users, :token, :string
  end
end
