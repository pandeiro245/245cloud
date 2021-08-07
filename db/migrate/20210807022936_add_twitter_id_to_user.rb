class AddTwitterIdToUser < ActiveRecord::Migration[5.2]
class AddTwitterIdToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :twitter_id, :string
  end
end
  def change
    add_column :users, :twitter_id, :string
  end
end
