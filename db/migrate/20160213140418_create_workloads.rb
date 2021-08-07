class CreateWorkloads < ActiveRecord::Migration[4.2]
  def change
    create_table :workloads do |t|
      t.integer :facebook_id
      t.string :key
      t.string :title
      t.boolean :is_done

      t.timestamps null: false
    end
  end
end
