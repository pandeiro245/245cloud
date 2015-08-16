class AddParsecomhashToRoom < ActiveRecord::Migration
  def change
    add_column :rooms, :parsecomhash, :string
  end
end
