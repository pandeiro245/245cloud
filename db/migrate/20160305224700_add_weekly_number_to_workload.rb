class AddWeeklyNumberToWorkload < ActiveRecord::Migration
  def change
    add_column :workloads, :weekly_number, :integer
  end
end
