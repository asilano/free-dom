class BaseGame::Moneylender < Card
  costs 4
  action
  card_text "Action (cost: 4) - Trash a Copper card from your hand. " +
                       "If you do, +3 cash."

  def play(parent_act)
    super

    card = player.cards.hand.of_type("BasicCards::Copper")[0]
    if card
      # Trash the selected card, and grant 3 cash.
      card.trash
      game.histories.create!(:event => "#{player.name} trashed a Copper from hand.",
                            :css_class => "player#{player.seat} card_trash")

      player.add_cash(3)
    else
      game.histories.create!(:event => "#{player.name} trashed nothing.",
                            :css_class => "player#{player.seat} card_trash")
    end

    "OK"
  end
end
