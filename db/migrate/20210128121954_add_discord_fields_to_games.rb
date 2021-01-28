class AddDiscordFieldsToGames < ActiveRecord::Migration[5.2]
  def change
    add_column :games, :discord_webhook, :string
    add_column :games, :last_notified_players, :json
  end
end
