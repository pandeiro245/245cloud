class AddNumberToWorkload < ActiveRecord::Migration
  def change
    add_column :workloads, :number, :integer
  end
end
