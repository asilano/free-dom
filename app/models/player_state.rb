class PlayerState < ActiveRecord::Base
  belongs_to :player
  serialize :gained_last_turn, Array
  
  before_validation_on_create :init_fields
  
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
    logger.info(self.inspect)
    save!
  end
end
