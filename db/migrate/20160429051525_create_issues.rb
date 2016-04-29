class CreateIssues < ActiveRecord::Migration
  def change
    create_table :issues do |t|
      t.references :user, index: true
      t.string :key
      t.integer :estimated
      t.integer :worked
      t.datetime :deadline

      t.timestamps null: false
    end
    add_foreign_key :issues, :users
  end
end
