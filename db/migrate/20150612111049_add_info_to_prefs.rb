class AddInfoToPrefs < ActiveRecord::Migration
  def change
    add_column :prefs, :info, :text
    add_column :cities, :info, :text
    add_column :postals, :info, :text
  end
end
