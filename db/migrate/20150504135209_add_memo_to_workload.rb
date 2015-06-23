class AddMemoToWorkload < ActiveRecord::Migration
  def change
    add_column :workloads, :memo, :text
  end
end
