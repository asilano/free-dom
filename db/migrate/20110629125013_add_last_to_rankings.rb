class AddLastToRankings < ActiveRecord::Migration
  def self.up
    add_column :rankings, :last_num_won, :integer, :default => 0
    add_column :rankings, :last_total_norm_pos, :float, :default => 0.0
    add_column :rankings, :last_total_score, :integer, :default => 0
    add_column :rankings, :last_result_elo, :float, :default => 1600
    add_column :rankings, :last_score_elo, :float, :default => 1600

    Ranking.where { num_played != 0}.update_all('last_num_won = num_won,
                        last_total_norm_pos = total_normalised_pos - (total_normalised_pos / num_played),
                        last_total_score = total_score - (total_score / num_played),
                        last_result_elo = result_elo,
                        last_score_elo = score_elo')

    Ranking.where { num_played != 0}.update_all('last_num_won = 0,
                        last_total_norm_pos = 0,
                        last_total_score = 0,
                        last_result_elo = 1600,
                        last_score_elo = 1600')
  end

  def self.down
    remove_column :rankings, :last_score_elo
    remove_column :rankings, :last_result_elo
    remove_column :rankings, :last_total_score
    remove_column :rankings, :last_total_norm_pos
    remove_column :rankings, :last_num_won
  end
end
