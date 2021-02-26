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

    validation do
      return true if journal.params['choice'] == 'none'
      return false unless journal.params['choice']&.integer?

      choice = journal.params['choice'].to_i
      choice < journal.player.hand_cards.length && journal.player.hand_cards[choice].treasure?
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
      card = player.hand_cards[params['choice'].to_i]
      card.play_as_treasure(played_by: player)

      # Ask again, unless the player now has no treasures in hand
      player.hand_cards.any?(&:treasure?) ? :continue : :stop
    end
  end
end
