# Peddler (Action - $8) - Draw a card, +1 Action, +1 Cash. / During your Buy phase, this costs 2 less per Action card you have in play, but not less than 0.

class Prosperity::Peddler < Card
  action
  costs 8
  card_text "Action (cost: 8) - Draw a card, +1 Action, +1 Cash. / During your Buy phase, this costs 2 less per Action card you have in play, but not less than 0."

  def play(parent_act)
    super

    player.draw_cards(1)
    player.add_actions(1, parent_act)
    player.cash += 1
    player.save!

    return "OK"
  end

  def cost
    # First get the baseline cost
    actual = super

    if game.turn_phase == Game::TurnPhases::BUY
      # Now adjust for Actions cards in play
      in_play = game.current_turn_player.cards.in_location("play", "enduring")
      actual = [0, actual - 2*(in_play.select {|c| c.is_action? }.length)].max
    end

    return actual
  end
end