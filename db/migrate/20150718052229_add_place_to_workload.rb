class AddPlaceToWorkload < ActiveRecord::Migration
  def change
    add_reference :workloads, :place, index: true
    add_foreign_key :workloads, :places
  end
end
