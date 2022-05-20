module GameEngine
  class PlayTreasuresJournal < Journal
    define_question('Play Treasures, or pass').prevent_auto
                                              .with_controls do |_game_state|
      [OneCardControl.new(journal_type: PlayTreasuresJournal,
                          question:     self,
                          player:       @player,
                          scope:        :hand,
                          text:         'Play',
                          filter:       :treasure?,
                          null_choice:  { text:  'Stop playing treasures',
                                          value: 'none' },
                          css_class:    'play-treasure')]
    end

    # For back-compatibility, allow arrays of choices
    validation do
      return true if params['choice'] == 'none'
      return false unless params['choice']
      return false unless Array(params['choice']).all?(&:integer?)

      Array(params['choice']).map(&:to_i).all? do |choice|
        choice < player.hand_cards.length && player.hand_cards[choice].treasure?
      end
    end

    process do |_game_state|
      # Tell the game if the player has stopped playing treasures
      if params['choice'] == 'none'
        @histories << History.new("#{player.name} stopped playing treasures (total: $#{player.cash})",
                                  player:      player,
                                  css_classes: %w[play-treasure])
        return :stop
      end

      # Play all the chosen cards in hand order
      cards = Array(params['choice']).map { |ch| player.hand_cards[ch.to_i] }
      cards.each { |card| card.play_card(played_by: player) }

      # Ask again, unless the player now has no treasures in hand
      player.hand_cards.any?(&:treasure?) ? :continue : :stop
    end

    class Template
      def matches?(journal)
        return true if super
        #return false unless
        journal.is_a? GameEngine::SpendCoffersJournal
      end
    end
  end
end
