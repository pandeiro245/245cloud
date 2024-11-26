class AddColumnsToAccessLogs < ActiveRecord::Migration[8.0]
  def change
    add_column :access_logs, :user_agent, :string
    add_column :access_logs, :ip_address, :string
    add_column :access_logs, :session_id, :string
    add_column :access_logs, :request_method, :string
    add_column :access_logs, :params, :json
  end
end
