class AddTwitterIdToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :twitter_id, :string

    add_column :workloads, :user_id, :integer
    add_column :comments, :user_id, :integer
    add_column :access_logs, :user_id, :integer

    # Sync.new.fb2user

    # remove_column :workloads, :facebook_id
    # remove_column :comments, :facebook_id
    # remove_column :access_logs, :facebook_id
  end
end
