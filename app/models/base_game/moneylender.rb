class BaseGame::Moneylender < Card
  costs 4
  action
  card_text "Action (cost: 4) - Trash a Copper card from your hand. " +
                       "If you do, +3 cash."

  def play
    super

    card = player.cards.hand.of_type("BasicCards::Copper")[0]
    if card
      # Trash the selected card, and grant 3 cash.
      card.trash
      game.add_history(:event => "#{player.name} trashed a Copper from hand.",
                            :css_class => "player#{player.seat} card_trash")

      player.cash += 3
    else
      game.add_history(:event => "#{player.name} trashed nothing.",
                            :css_class => "player#{player.seat} card_trash")
    end
  end
end
