class RenameCafeToPlace < ActiveRecord::Migration
  def change
    rename_table :caves, :places
  end
end
