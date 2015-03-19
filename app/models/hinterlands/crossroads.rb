class Hinterlands::Crossroads < Card
  costs 2
  action
  card_text "Action (cost: 2) - Reveal your hand. Draw 1 card per Victory card revealed. If this is the first time you played a Crossroads this turn, +3 Actions."

  def play(parent_act)
    super

    # "Reveal" the hand (actually, just stick it in history, since it doesn't
    # need to be persistently visible)
    game.histories.create!(:event => "#{player.name} revealed their hand to #{self}:",
                          :css_class => "player#{player.seat} card_reveal")
    game.histories.create!(:event => "#{player.name} revealed #{player.cards.hand.join(', ')}.",
                          :css_class => "player#{player.seat} card_reveal")

    player.draw_cards(player.cards.hand.select(&:is_victory?).length)

    # Grant actions if this is the first Crossroads this turn
    if !player.state.played_crossroads
      player.add_actions(3, parent_act)
      game.histories.create!(:event => "#{player.name} gained 3 actions from first play of #{self}.",
                             :css_class => "player#{player.seat}")
    end

    player.state.played_crossroads = true
    player.state.save!

    "OK"
  end
end
