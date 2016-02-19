class RenameKeyOfWorkload < ActiveRecord::Migration
  def change
    rename_column :workloads, :key, :music_key
  end
end
