module GameEngine
  module BaseGameV2
    class Chapel < GameEngine::Card
      text 'Action (cost: 2)',
           'Trash up to 4 cards from your hand.'
      action
      costs 2

      def play_as_action(played_by:)
        super

        game_state.get_journal(TrashCardsJournal, from: played_by).process(game_state)
      end

      class TrashCardsJournal < Journal
        define_question('Trash up to 4 cards').with_controls do |game_state|
          [MultiCardControl.new(journal_type: TrashCardsJournal,
                                question:     self,
                                player:       @player,
                                scope:        :hand,
                                text:         'Trash',
                                submit_text:  'Trash selected cards',
                                css_class:    'trash')]
        end

        validation do
          return true if journal.params['choice'].blank?
          return false if journal.params['choice'].length > 4
          return false unless journal.params['choice']&.all?(&:integer?)

          journal.params['choice'].all? do |choice|
            choice.to_i < journal.player.hand_cards.length
          end
        end

        process do |game_state|
          # Just log if the player chose nothing
          if params['choice'].blank?
            @histories << History.new("#{player.name} trashed nothing",
                                      player:      player,
                                      css_classes: %w[trash])
            return
          end

          # Trash all the chosen cards in hand order
          cards = params['choice'].map { |ch| player.hand_cards[ch.to_i] }
          texts_for_history = cards.map(&:readable_name)
          cards.each { |c| c.trash(from: player.cards) }

          @histories << History.new("#{player.name} trashed #{texts_for_history.join(', ')}",
                                    player:      player,
                                    css_classes: %w[trash])
        end
      end
    end
  end
end
