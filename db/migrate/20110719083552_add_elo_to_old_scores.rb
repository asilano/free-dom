class AddEloToOldScores < ActiveRecord::Migration
  def self.up
    add_column :old_scores, :result_elo, :float
    add_column :old_scores, :score_elo, :float
  end

  def self.down
    remove_column :old_scores, :score_elo
    remove_column :old_scores, :result_elo
  end
end
