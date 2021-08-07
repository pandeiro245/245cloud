class AddWeeklyNumberToWorkload < ActiveRecord::Migration[4.2]
  def change
    add_column :workloads, :weekly_number, :integer
  end
end
