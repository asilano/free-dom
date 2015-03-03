class BaseGame::Moat < Card
  costs 2
  action
  reaction
  card_text "Action (Reaction; cost: 2) - Draw 2 cards. When another player plays an " +
                                 "Attack card, you may reveal this from your " +
                                 "hand. If you do, you are unaffected by " +
                                 "that Attack."

  def play(parent_act)
    super

    # Just draw two cards
    player.draw_cards(2)

    "OK"
  end

  def react(attack_action, parent_act)
    # The Moat just negates the attack action.
    game.histories.create!(:event => "#{player.name} reacted with a Moat, negating the attack.",
                          :css_class => "player#{player.seat} play_reaction")

    moat_attack(attack_action, player)

    "OK"
  end
end
