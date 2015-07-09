class AddParseidToUserAndWorkloadAndComment < ActiveRecord::Migration
  def change
    add_column :users, :parsecomhash, :string
    add_column :workloads, :parsecomhash, :string
    add_column :comments, :parsecomhash, :string
  end
end
