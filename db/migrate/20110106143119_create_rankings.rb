class CreateRankings < ActiveRecord::Migration
  def self.up
    create_table :rankings do |t|
      t.integer :user_id
      t.integer :num_played, :default => 0
      t.integer :num_won, :default => 0
      t.float :total_normalised_pos, :default => 0
      t.integer :total_score, :default => 0
      t.float :result_elo, :default => 1600
      t.float :score_elo, :default => 1600

      t.timestamps
    end    
    
    User.all.each do |u|
      say "Adding rankings for #{u.name}"
      u.create_ranking
    end
  end

  def self.down
    drop_table :rankings
  end
end
