class AddDiscordUidToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :discord_uid, :string
  end
end
