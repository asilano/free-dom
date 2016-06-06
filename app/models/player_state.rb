class PlayerState

  attr_accessor :outpost_queued, :outpost_prevent, :pirate_coins, :gained_last_turn,
                :bought_victory, :played_treasure, :played_crossroads, :played_fools_gold

  def init_fields
    @gained_last_turn ||= []
  end

  # Reset fields which last turn-to-turn
  def reset_fields
    @outpost_queued = false
    # outpost_prevent is set and reset at end of previous turn
    # pirate_coins persists turn after turn
    @gained_last_turn = []
    @bought_victory = false
    @played_treasure = false
    @played_crossroads = false
    @played_fools_gold = false
  end
end
