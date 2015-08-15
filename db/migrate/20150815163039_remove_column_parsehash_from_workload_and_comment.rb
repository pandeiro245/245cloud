class RemoveColumnParsehashFromWorkloadAndComment < ActiveRecord::Migration
  def change
    remove_column :workloads, :parsehash
    remove_column :comments, :parsehash
  end
end
