class Hinterlands::Highway < Card
  action
  costs 5
  card_text "Action (costs: 5) - Draw 1 card, +1 Action. / " +
            "While this is in play, cards cost 1 cash less, but not less than 0."

  def play(parent_act)
    super

    # Draw the card, add the action
    player.draw_cards(1)
    player.add_actions(1, parent_act)

    # Cost reduction is handled by Card#cost
    "OK"
  end
end