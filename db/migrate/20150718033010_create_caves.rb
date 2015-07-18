class CreateCaves < ActiveRecord::Migration
  def change
    create_table :caves do |t|
      t.string :name
      t.references :pref, index: true
      t.references :city, index: true

      t.timestamps null: false
    end
    add_foreign_key :caves, :prefs
    add_foreign_key :caves, :cities
  end
end
