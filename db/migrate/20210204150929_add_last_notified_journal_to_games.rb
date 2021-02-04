class AddLastNotifiedJournalToGames < ActiveRecord::Migration[5.2]
  def change
    add_column :games, :last_notified_journal, :integer
  end
end
