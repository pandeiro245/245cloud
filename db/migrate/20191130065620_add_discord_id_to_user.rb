class AddDiscordIdToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :discord_id, :string
  end
end
