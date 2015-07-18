class RenameZipToPostal < ActiveRecord::Migration
  def change
    rename_table :zips, :postals
    add_column :postals, :lot, :string
    add_column :postals, :flag1, :integer
    add_column :postals, :flag2, :integer
    add_column :postals, :flag3, :integer
    add_column :postals, :flag4, :integer
    add_column :postals, :flag5, :integer
    add_column :postals, :flag6, :integer
  end
end
