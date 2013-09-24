class AddTurnPhaseToGames < ActiveRecord::Migration
  def change
    add_column :games, :turn_phase, :integer
  end
end
