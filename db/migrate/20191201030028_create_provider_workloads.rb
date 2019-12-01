class CreateProviderWorkloads < ActiveRecord::Migration[5.2]
  def change
    create_table :provider_workloads do |t|
      t.references :workload, foreign_key: true
      t.references :provider, foreign_key: true
      t.references :provider_user, foreign_key: true
      t.string :key
      t.text :val

      t.timestamps
    end
  end
end
