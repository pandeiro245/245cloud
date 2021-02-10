class AddUserToWorkload < ActiveRecord::Migration[5.2]
  def change
    add_reference :workloads, :user, foreign_key: true
  end
end
