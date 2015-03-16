class Hinterlands::NomadCamp < Card
  action
  costs 4
  card_text "Action (cost: 4) - +1 Buy, +2 Cash / When you gain this, put it on top of your deck."

  def play(parent_act)
    # Playing is exactly the same as a Woodcutter.
    super

    # Give the player an additional Buy, and 2 cash.
    player.add_buys(1, parent_act)
    player.add_cash(2)

    "OK"
  end

  # Notice a gain event before it happens. If it's Nomad Camp itself, change the gain
  # location to be top of the deck
  def self.witness_pre_gain_modify(params)
    card = params[:card] || params[:pile].cards.first

    if card.class == self
      params[:location] = 'deck'
      params[:position] = 0
    end
  end
end