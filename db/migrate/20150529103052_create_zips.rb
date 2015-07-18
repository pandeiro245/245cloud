class CreateZips < ActiveRecord::Migration
  def change
    create_table :zips do |t|
      t.string :code
      t.references :pref, index: true, foreign_key: true
      t.references :city, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
