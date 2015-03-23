class AddUserIdToWorkload < ActiveRecord::Migration
  def change
    add_column :workloads, :user_id, :integer
    remove_column :workloads, :user_hash
  end
end
