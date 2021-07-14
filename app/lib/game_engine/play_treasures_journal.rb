module GameEngine
  class PlayTreasuresJournal < Journal
    define_question('Play Treasures, or pass').prevent_auto
                                              .with_controls do |_game_state|
      ctrls = []
      ctrls << OneCardControl.new(journal_type: PlayTreasuresJournal,
                                  question:     self,
                                  player:       @player,
                                  scope:        :hand,
                                  text:         'Play',
                                  filter:       :treasure?,
                                  null_choice:  { text:  'Stop playing treasures',
                                                  value: 'none' },
                                  css_class:    'play-treasure')

      if @player.coffers.positive?
        ctrls << NumberControl.new(journal_type: SpendCoffersJournal,
                                   question:     self,
                                   player:       @player,
                                   scope:        :with_hand,
                                   min:          1,
                                   max:          @player.coffers,
                                   text:         "Coffers to spend (max: #{@player.coffers})",
                                   submit_text:  'Spend coffers')
      end
      ctrls
    end

    # For back-compatibility, allow arrays of choices
    validation do
      return true if journal.params['choice'] == 'none'
      return false unless journal.params['choice']
      return false unless Array(journal.params['choice']).all?(&:integer?)

      Array(journal.params['choice']).map(&:to_i).all? do |choice|
        choice < journal.player.hand_cards.length && journal.player.hand_cards[choice].treasure?
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
      cards.each { |card| card.play_as_treasure(played_by: player) }

      # Ask again, unless the player now has no treasures in hand
      player.hand_cards.any?(&:treasure?) ? :continue : :stop
    end

    class Template
      def matches?(journal)
        return true if super
        return false unless journal.is_a? GameEngine::SpendCoffersJournal

        define_singleton_method(:journal) { journal }
        valid? journal
      end
    end
  end
end
