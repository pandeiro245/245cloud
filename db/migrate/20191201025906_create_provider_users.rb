class CreateProviderUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :provider_users do |t|
      t.references :user, foreign_key: true
      t.references :provider, foreign_key: true
      t.string :key

      t.timestamps
    end
  end
end
