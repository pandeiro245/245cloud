class AddNumberToWorkload < ActiveRecord::Migration[4.2]
  def change
    add_column :workloads, :number, :integer
  end
end
