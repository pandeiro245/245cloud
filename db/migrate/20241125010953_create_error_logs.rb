class CreateErrorLogs < ActiveRecord::Migration[8.0]
  def change
    create_table :error_logs do |t|
      t.string :error_class
      t.text :error_message
      t.text :backtrace
      t.references :user, null: false, foreign_key: true
      t.string :url
      t.json :params
      t.string :user_agent
      t.string :ip_address
      t.string :session_id
      t.string :request_method

      t.timestamps
    end
  end
end
