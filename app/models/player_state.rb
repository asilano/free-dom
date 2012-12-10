class PlayerState < ActiveRecord::Base
  belongs_to :player
  serialize :gained_last_turn, Array

  before_validation :init_fields, :on => :create

  def init_fields
    self.gained_last_turn ||= []
  end

  # Reset fields which last turn-to-turn
  def reset_fields
    self.outpost_queued = false
    # outpost_prevent is set and reset at end of previous turn
    # pirate_coins persists turn after turn
    self.gained_last_turn = []
    self.bought_victory = false
    self.played_treasure = false
    self.played_crossroads = false
    self.played_fools_gold = false
    save!
  end
end
