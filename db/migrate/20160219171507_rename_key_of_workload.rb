class RenameKeyOfWorkload < ActiveRecord::Migration[4.2]
  def change
    rename_column :workloads, :key, :music_key
  end
end
