# 11  Caravan  Seaside  Action - Duration  $4  +1 Card, +1 Action.  At the start of your next turn, +1 Card.

class Seaside::Caravan < Card
  costs 4
  action :duration => true
  card_text "Action (Duration; cost: 4) - Draw 1 card, +1 Action. At the start of your next turn, draw 1 card."

  def play(parent_act)
    super

    # Just draw a card and add an action
    player.draw_cards(1)
    player.add_actions(1, parent_act)

    return "OK"
  end

  def end_duration(parent_act)
    super

    # Draw a card
    player.draw_cards(1)

    return "OK"
  end
end
