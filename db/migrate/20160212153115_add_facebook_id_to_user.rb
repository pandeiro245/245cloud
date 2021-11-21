class AddFacebookIdToUser < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :facebook_id, :integer
  end
end
