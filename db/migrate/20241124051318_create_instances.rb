class CreateInstances < ActiveRecord::Migration[8.0]
  def change
    create_table :instances do |t|
      t.string :host
      t.string :db_service
      t.string :status
      t.text :json_data

      t.timestamps
    end
  end
end
