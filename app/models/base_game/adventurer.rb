class BaseGame::Adventurer < Card
  costs 6
  action
  card_text "Action (cost: 6) - Reveal cards from your deck until you reveal two " +
                       "Treasure cards. Put those Treasure cards into your " +
                       "hand, and discard the other revealed cards."

  def play
    super

    # We don't really need to actually reveal the cards here; putting them
    # straight onto discard will work fine, with one caveat. We need to know
    # whether the existing discard pile will get shuffled under the deck first.
    #
    # So, step through the deck counting Treasures. If we don't find two,
    # shuffle the discard pile under. Then step through the deck (possibly plus
    # old discard) and move each card to hand or discard until we're done.
    treasure_count = 0
    player.cards.deck.each do |card|
      treasure_count += 1 if card.is_treasure?
      break if treasure_count == 2
    end

    shuffle_point = player.cards.deck.count
    if treasure_count < 2
      player.shuffle_discard_under_deck(:log => shuffle_point == 0)
    end

    treasure_count = 0
    cards_revealed = []
    player.cards.deck.each do |card|
      cards_revealed << card.class.readable_name
      if card.is_treasure?
        treasure_count += 1
        card.position = player.cards.hand.size - 1
        card.location = "hand"
        break if treasure_count == 2
      else
        card.discard
      end
    end

    # And finally, create the history
    if shuffle_point > 0 && shuffle_point < cards_revealed.length
      cards_revealed.insert(shuffle_point, "(#{player.name} shuffled their discards)")
    end

    game.add_history(:event => "#{player.name}'s Adventurer revealed: #{cards_revealed.join(', ')}.",
                      :css_class => "player#{player.seat} card_reveal #{'shuffle' if (shuffle_point > 0 && shuffle_point < cards_revealed.length)}")

    return "OK"
  end
end
