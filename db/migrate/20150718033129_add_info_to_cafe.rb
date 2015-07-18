class AddInfoToCafe < ActiveRecord::Migration
  def change
    add_column :caves, :info, :text
  end
end
