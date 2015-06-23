class RenameColumnIsDoneToStatus < ActiveRecord::Migration
  def change
    rename_column :workloads, :is_done, :status
    change_column :workloads, :status, :integer, limit: 1, default: 0
  end
end
