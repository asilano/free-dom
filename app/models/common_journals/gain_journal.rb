module CommonJournals
  class GainJournal < Journal
    attr_reader :card

    def self.configure(question_text:  nil,
                       question_block: nil,
                       filter:         nil,
                       destination:    :discard,
                       source:         :supply)
      define_question(question_text, &question_block).with_controls do |game_state|
        bound_filter = ->(*args) { instance_exec(*args, &filter) } if filter
        from_cards = case source
        when :supply
          game_state.piles.map(&:cards).map(&:first)
        when :trash
          game_state.trashed_cards
        end
        [OneCardControl.new(journal_type: journal_type,
                            question:     self,
                            player:       @player,
                            scope:        source,
                            text:         'Gain',
                            filter:       filter,
                            null_choice:  if filter && from_cards.none?(&bound_filter)
                                            { text: 'Gain nothing', value: 'none' }
                                          end,
                            css_class:    'gain-card')]
      end

      process do |game_state|
        if params['choice'] == 'none'
          @histories << GameEngine::History.new("#{player.name} gained nothing.",
                                                player:      player,
                                                css_classes: %w[gain-card])
        else
          case source
          when :supply
            pile = game_state.piles[params['choice'].to_i]
            @card = pile.cards.first
            from = pile.cards
          when :trash
            @card = game_state.trashed_cards[params["choice"].to_i]
            from = game_state.trashed_cards
          end

          @histories << GameEngine::History.new("#{player.name} gained #{card.readable_name}#{" from #{source}" unless source == :supply}#{" to their #{destination}" unless destination == :discard}.",
                                                player:      player,
                                                css_classes: %w[gain-card])
          card.be_gained_by(player, from: from, to: destination)
          observe
        end

        post_process if respond_to?(:post_process)
      end
    end
  end
end
