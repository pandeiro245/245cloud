class RemoveTitleFromWorkload < ActiveRecord::Migration
  def change
    remove_column :workloads, :title
  end
end
