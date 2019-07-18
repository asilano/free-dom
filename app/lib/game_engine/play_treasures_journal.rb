module GameEngine
  class PlayTreasuresJournal < Journal
    define_question('Play Treasures, or pass').with_controls do |_game_state|
      [MultiCardControl.new(player: @player,
                            scope: :hand,
                            text: 'Play',
                            filter: ->(card) { card.treasure? },
                            preselect: ->(card) { !card.special? },
                            submit_text: 'Play selected treasures (select none to stop)',
                            css_class: 'play-treasure')]
    end

    validation do
      return true if journal.params['choice'].blank?
      return false unless journal.params['choice'].all?(&:integer?)

      journal.params['choice'].all? do |choice|
        choice.to_i < journal.player.hand_cards.length && journal.player.hand_cards[choice.to_i].treasure?
      end
    end

    process do |_game_state|
      # Tell the game if the player has stopped playing treasures
      return :stop if params['choice'].blank?

      # Play all the chosen cards in hand order
      cards = params['choice'].map { |ch| player.hand_cards[ch.to_i] }
      texts_for_history = []
      cards.each do |card|
        player.played_cards << card
        player.hand_cards.delete card
        cash_gain = card.cash
        player.cash += cash_gain

        texts_for_history << "#{card.readable_name} ($#{cash_gain})"
      end

      @histories << History.new("#{player.name} played #{texts_for_history.join(', ')} (total: $#{player.cash})",
                                player: player,
                                css_classes: %w[play-treasure])

      # Ask again, unless the player now has no treasures in hand
      player.hand_cards.any?(&:treasure?) ? :continue : :stop
    end
  end
end
