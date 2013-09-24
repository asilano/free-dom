class Hinterlands::Cache < Card
  costs 5
  treasure :cash => 3
  card_text "Treasure (cost: 5) - 3 Cash. When you gain this, gain two Coppers."

  # Notice a gain event. If it's Cache itself, gain two Coppers.
  def self.witness_gain(params)
    ply = params[:gainer]
    card = params[:card]
    parent_act = params[:parent_act]
    game = ply.game

    # Check whether the card gained is Cache, and if so request gain of two Coppers
    if card.class == self
      coppers = game.piles.find_by_card_type("BasicCards::Copper")
      2.times {ply.gain(parent_act, :pile => coppers)}
    end

    # Cache's Copper gains don't affect the gain of Cache at all
    return false
  end
end