class CreateOldScores < ActiveRecord::Migration
  def self.up
    create_table :old_scores do |t|
      t.integer :game_id
      t.integer :user_id
      t.integer :score
    end
  end

  def self.down
    drop_table :old_scores
  end
end
